class EmailVerification < ApplicationRecord
  # Associations
  belongs_to :verifiable, polymorphic: true

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :verification_token, presence: true
  validates :verifiable_type, presence: true
  validates :verifiable_id, presence: true

  # Scopes
  scope :pending, -> { where(verified_at: nil) }
  scope :verified, -> { where.not(verified_at: nil) }
  scope :expired, -> { where('created_at < ?', 24.hours.ago) }
  scope :active, -> { where('created_at >= ?', 24.hours.ago) }

  # Include token generation concern
  include TokenGeneratable
  
  # Callbacks
  before_validation :generate_verification_token, on: :create
  before_validation :downcase_email

  # Instance methods
  def verified?
    verified_at.present?
  end

  def expired?
    created_at < 24.hours.ago
  end

  def active?
    !expired? && !verified?
  end

  # Note: verify_with_token! method removed - business logic moved to EmailVerificationService
  # The service now handles token validation, verification marking, and verifiable attribute updates
  # This method is kept for backward compatibility but should not be used directly
  # Use EmailVerificationService#verify_email_with_token instead
  def verify_with_token!(token)
    return false if expired? || verified?
    return false if verification_token.blank? || token.blank?
    return false unless ActiveSupport::SecurityUtils.secure_compare(verification_token, token)

    update!(verified_at: Time.current)
    true
  end

  def resend_verification!
    return false if verified?
    
    update!(verification_token: generate_unique_token_for(:verification_token), created_at: Time.current)
    true
  end

  private

  def generate_verification_token
    self.verification_token = generate_unique_token_for(:verification_token) if verification_token.blank?
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end
end





