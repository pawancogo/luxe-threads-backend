class Supplier < ApplicationRecord
  # Include concerns for shared behavior
  include Passwordable
  include Verifiable
  include Auditable

  # Define supplier roles using an enum
  enum :role, {
    basic_supplier: 'basic_supplier',
    verified_supplier: 'verified_supplier',
    premium_supplier: 'premium_supplier',
    partner_supplier: 'partner_supplier'
  }

  # Associations
  has_one :supplier_profile, dependent: :destroy
  has_many :products, through: :supplier_profile

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true

  # Callback replaced by service
  after_create :send_verification_email

  # Helper methods for role checking
  def verified?
    verified_supplier? || premium_supplier? || partner_supplier?
  end

  def premium?
    premium_supplier? || partner_supplier?
  end

  def partner?
    partner_supplier?
  end

  def can_upload_unlimited_products?
    premium_supplier? || partner_supplier?
  end

  def can_access_analytics?
    verified_supplier? || premium_supplier? || partner_supplier?
  end

  def can_manage_team?
    partner_supplier?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Business logic methods
  def send_verification_email_with_temp_password
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.verification_email(self, temp_password, 'supplier').deliver_now
    temp_password
  end

  def send_password_reset_email
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.password_reset_email(self, temp_password, 'supplier').deliver_now
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

  private

  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end
end
