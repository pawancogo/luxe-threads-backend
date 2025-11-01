class Admin < ApplicationRecord
  # Custom password hashing with argon2
  attr_accessor :password
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 }, if: :password_required?
  
  # PaperTrail for audit logging
  has_paper_trail
  
  # Soft delete functionality
  acts_as_paranoid

  # Define admin roles using an enum
  enum :role, {
    super_admin: 'super_admin',        # Full system access
    product_admin: 'product_admin',    # Product management only
    order_admin: 'order_admin',        # Order management only
    user_admin: 'user_admin',          # User management only
    supplier_admin: 'supplier_admin'   # Supplier management only
  }

  # Associations
  has_many :email_verifications, as: :verifiable, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true
  validate :password_requirements, if: :password_required?

  # Callbacks
  after_create :send_verification_email, unless: :super_admin?

  # Helper methods for role checking
  def can_manage_products?
    super_admin? || product_admin?
  end

  def can_manage_orders?
    super_admin? || order_admin?
  end

  def can_manage_users?
    super_admin? || user_admin?
  end

  def can_manage_suppliers?
    super_admin? || supplier_admin?
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

  # Generic verification methods
  def send_verification_email_with_temp_password
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.verification_email(self, temp_password, 'admin').deliver_now
    temp_password
  end

  def send_password_reset_email
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.password_reset_email(self, temp_password, 'admin').deliver_now
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

  def password_requirements
    return unless password.present?
    
    errors = PasswordValidationService.errors(password)
    errors.each { |error| self.errors.add(:password, error) }
  end

  def password_required?
    password.present? && !password_reset_required?
  end

  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end
end
