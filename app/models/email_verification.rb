class EmailVerification < ApplicationRecord
  # Associations
  belongs_to :verifiable, polymorphic: true

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :otp, presence: true, length: { is: 6 }
  validates :verifiable_type, presence: true
  validates :verifiable_id, presence: true

  # Scopes
  scope :pending, -> { where(verified_at: nil) }
  scope :verified, -> { where.not(verified_at: nil) }
  scope :expired, -> { where('created_at < ?', 15.minutes.ago) }
  scope :active, -> { where('created_at >= ?', 15.minutes.ago) }

  # Callbacks
  before_validation :generate_otp, on: :create
  before_validation :downcase_email

  # Instance methods
  def verified?
    verified_at.present?
  end

  def expired?
    created_at < 15.minutes.ago
  end

  def active?
    !expired? && !verified?
  end

  def verify!(entered_otp)
    return false if expired? || verified?
    return false if otp != entered_otp.to_s

    update!(verified_at: Time.current)
    
    # Update verifiable attributes
    if verifiable.respond_to?(:email_verified=)
      verifiable.update!(email_verified: true)
    end
    
    # Activate the account when email is verified
    if verifiable.respond_to?(:is_active=)
      verifiable.update!(is_active: true) unless verifiable.is_active?
    end
    
    # For users, also reactivate if they were soft deleted
    if verifiable.is_a?(User) && verifiable.respond_to?(:deleted_at=)
      verifiable.update!(deleted_at: nil) if verifiable.deleted_at.present?
    end
    
    true
  end

  def resend_otp!
    return false if verified?
    
    update!(otp: generate_otp_code, created_at: Time.current)
    true
  end

  private

  def generate_otp
    self.otp = generate_otp_code if otp.blank?
  end

  def generate_otp_code
    rand(100000..999999).to_s
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end
end





