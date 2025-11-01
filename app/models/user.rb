class User < ApplicationRecord
  # Custom password hashing with argon2
  attr_accessor :password
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 }, if: :password_required?
  
  # PaperTrail for audit logging
  has_paper_trail
  
  # Soft delete functionality
  acts_as_paranoid

  # Define customer roles using an enum
  enum :role, {
    customer: 'customer',
    premium_customer: 'premium_customer',

    vip_customer: 'vip_customer',
    supplier: 'supplier'
  }

  # Associations
  has_one :supplier_profile, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_many :verified_products, class_name: 'Product', foreign_key: 'verified_by_admin_id'
  has_many :email_verifications, as: :verifiable, dependent: :destroy
  after_create :create_cart
  after_create :create_wishlist
  after_create :send_verification_email

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true

  # Helper methods for customer roles
  def premium?
    premium_customer? || vip_customer?
  end

  def vip?
    vip_customer?
  end

  # Check if user is a supplier (has supplier_profile)
  def supplier?
    supplier_profile.present? || role == 'supplier'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end

  def resend_verification_email
    EmailVerificationService.new(self).resend_verification_email
  end

  def verify_email_with_otp(otp)
    EmailVerificationService.new(self).verify_email_with_otp(otp)
  end

  # Generic verification methods for temporary passwords
  def send_verification_email_with_temp_password
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.verification_email(self, temp_password, 'user').deliver_now
    temp_password
  end

  def send_password_reset_email
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.password_reset_email(self, temp_password, 'user').deliver_now
    temp_password
  end

  def authenticate_with_temp_password(temp_password)
    TempPasswordService.authenticate_temp_password(self, temp_password)
  end

  def reset_password_with_temp_password(temp_password, new_password)
    return false unless authenticate_with_temp_password(temp_password)
    return false unless PasswordValidationService.valid?(new_password)
    
    update!(password: new_password)
    TempPasswordService.clear_temp_password(self)
    true
  end

  def temp_password_expired?
    TempPasswordService.temp_password_expired?(self)
  end

  # Password authentication methods
  def authenticate(password)
    return false if password_digest.blank?
    PasswordHashingService.verify_password(password, password_digest)
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = PasswordHashingService.hash_password(new_password) if new_password.present?
  end

  private

  def password_required?
    password.present? && !password_reset_required?
  end

  def create_cart
    Cart.create(user: self)
  end

  def create_wishlist
    Wishlist.create(user: self)
  end

  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end
end