class Supplier < ApplicationRecord
  # Include concerns for shared behavior
  include Passwordable
  include Verifiable
  include Auditable
  include Roleable
  include Nameable

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

  # Note: Email sending is handled by services, not callbacks
  # This follows Clean Architecture - business logic in services, not models

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

  # Business logic methods - delegate to services
  # Note: Email sending is handled by services (EmailVerificationService, PasswordResetService)
  
  def authenticate_with_temp_password(temp_password)
    Authentication::TempPasswordService.authenticate_temp_password(self, temp_password)
  end

  # Deprecated: Use PasswordResetCompletionService instead
  def reset_password_with_temp_password(temp_password, new_password)
    service = Authentication::PasswordResetCompletionService.new(self, temp_password, new_password)
    service.call
    service.success?
  end

  def temp_password_expired?
    Authentication::TempPasswordService.temp_password_expired?(self)
  end
end
