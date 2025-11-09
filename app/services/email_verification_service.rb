# frozen_string_literal: true

# Service for handling email verification flow
# Handles OTP generation, sending, and verification
class EmailVerificationService
  attr_reader :verifiable

  def initialize(verifiable)
    @verifiable = verifiable
  end

  def send_verification_email
    return false if verifiable.email_verified?
    
    # Clean up any existing verifications for this email to avoid unique constraint violations
    # The email_verifications table has a unique index on email, so we need to remove all existing ones
    EmailVerification.where(email: verifiable.email.downcase).destroy_all
    
    create_and_send_verification
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid => e
    handle_constraint_violation(e)
  end

  def resend_verification_email
    return false if verifiable.email_verified?
    
    verification = find_active_verification
    
    if verification&.active?
      send_otp_email(verification)
      true
    else
      send_verification_email.present?
    end
  end

  def verify_email_with_otp(otp)
    verification = find_active_verification
    
    return failure_response('No pending verification found') unless verification
    return failure_response('OTP has expired') if verification.expired?
    
    verification.verify!(otp) ? success_response : failure_response('Invalid OTP')
  end

  def verification_status
    return 'verified' if verifiable.email_verified?
    
    verification = find_active_verification
    return 'pending' if verification
    return 'expired' if has_expired_verifications?
    
    'none'
  end

  private

  def create_and_send_verification
    # Since we've already destroyed all existing verifications for this email,
    # we can safely create a new one. Use find_or_initialize_by as a safety net
    # for race conditions where multiple requests happen simultaneously.
    verification = EmailVerification.find_or_initialize_by(email: verifiable.email.downcase) do |v|
      v.verifiable = verifiable
    end
    
    # If it's an existing record (race condition), reset it to create a new verification
    if verification.persisted?
      # Delete and recreate to get fresh timestamps and OTP
      verification.destroy
      verification = verifiable.email_verifications.build(email: verifiable.email.downcase)
    end
    
    verification.save!
    send_otp_email(verification)
    verification
  end

  def handle_constraint_violation(error)
    # Handle race conditions where verification is created simultaneously
    Rails.logger.warn "Constraint violation for #{verifiable.email}: #{error.message}"
    verifiable.email_verifications.pending.first
  end

  def find_active_verification
    verifiable.email_verifications.pending.active.first
  end

  def has_expired_verifications?
    verifiable.email_verifications.pending.expired.exists?
  end

  def success_response(message = 'Email verified successfully')
    { success: true, message: message }
  end

  def failure_response(message)
    { success: false, message: message }
  end

  def send_otp_email(verification)
    Rails.logger.info "Attempting to send OTP email to #{verification.email}"
    
    success = EmailDeliveryService.deliver(-> { EmailVerificationMailer.send_otp(verification) })
    
    return true if success

    fallback_in_development(verification)
  end

  def fallback_in_development(verification)
    return false unless Rails.env.development?

    log_otp_to_console(verification)
    true
  end

  def log_otp_to_console(verification)
    expires_at = verification.created_at + Rails.application.config.otp_expiry_minutes.minutes
    
    Rails.logger.info '=' * 50
    Rails.logger.info 'EMAIL VERIFICATION OTP (DEVELOPMENT)'
    Rails.logger.info '=' * 50
    Rails.logger.info "To: #{verification.email}"
    Rails.logger.info "OTP: #{verification.otp}"
    Rails.logger.info "Expires: #{expires_at}"
    Rails.logger.info "Verification URL: #{verification_url(verification)}"
    Rails.logger.info '=' * 50
  end

  def verification_url(verification)
    base_url = build_base_url
    params = build_verification_params(verification)
    "#{base_url}/verify-email?#{params}"
  end

  def build_base_url
    config = Rails.application.config
    protocol = Rails.env.production? ? 'https' : 'http'
    port = Rails.env.production? ? '' : ":#{config.port}"
    "#{protocol}://#{config.host}#{port}"
  end

  def build_verification_params(verification)
    {
      type: verification.verifiable_type.downcase,
      id: verification.verifiable_id,
      email: verification.email
    }.to_query
  end
end
