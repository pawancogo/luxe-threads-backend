class EmailVerificationService
  attr_reader :verifiable

  def initialize(verifiable)
    @verifiable = verifiable
  end

  def send_verification_email
    return false if verifiable.email_verified?
    
    # Clean up any existing pending verifications
    verifiable.email_verifications.pending.destroy_all
    
    # Create new verification record
    verification = verifiable.email_verifications.create!(
      email: verifiable.email
    )
    
    # Send email (placeholder for now - will be implemented with SMTP)
    send_otp_email(verification)
    
    verification
  end

  def resend_verification_email
    return false if verifiable.email_verified?
    
    # Find or create verification record
    verification = verifiable.email_verifications.pending.first
    
    if verification&.active?
      # Resend existing OTP
      send_otp_email(verification)
    else
      # Create new verification
      send_verification_email
    end
  end

  def verify_email_with_otp(otp)
    verification = verifiable.email_verifications.pending.active.first
    
    return { success: false, message: 'No pending verification found' } unless verification
    return { success: false, message: 'OTP has expired' } if verification.expired?
    
    if verification.verify!(otp)
      { success: true, message: 'Email verified successfully' }
    else
      { success: false, message: 'Invalid OTP' }
    end
  end

  def verification_status
    return 'verified' if verifiable.email_verified?
    
    verification = verifiable.email_verifications.pending.active.first
    return 'pending' if verification
    return 'expired' if verifiable.email_verifications.pending.expired.any?
    
    'none'
  end

  private

  def send_otp_email(verification)
    # Check if we should skip email verification in development
    if Rails.env.development? && Rails.application.config.skip_email_verification_in_dev
      Rails.logger.info "Skipping email verification in development"
      return true
    end

    # Check if we should log emails to console instead of sending
    if Rails.env.development? && Rails.application.config.log_emails_to_console
      log_otp_to_console(verification)
      return true
    end

    # Send actual email in production or when configured
    begin
      EmailVerificationMailer.send_otp(verification).deliver_now
      Rails.logger.info "OTP email sent successfully to #{verification.email}"
      true
    rescue => e
      Rails.logger.error "Failed to send OTP email: #{e.message}"
      false
    end
  end

  def log_otp_to_console(verification)
    Rails.logger.info "=" * 50
    Rails.logger.info "EMAIL VERIFICATION OTP (DEVELOPMENT)"
    Rails.logger.info "=" * 50
    Rails.logger.info "To: #{verification.email}"
    Rails.logger.info "OTP: #{verification.otp}"
    Rails.logger.info "Expires: #{verification.created_at + Rails.application.config.otp_expiry_minutes.minutes}"
    Rails.logger.info "Verification URL: #{verification_url(verification)}"
    Rails.logger.info "=" * 50
  end

  def verification_url(verification)
    host = Rails.application.config.host
    port = Rails.application.config.port
    protocol = Rails.env.production? ? 'https' : 'http'
    
    "#{protocol}://#{host}:#{port}/verify-email?type=#{verification.verifiable_type.downcase}&id=#{verification.verifiable_id}&email=#{verification.email}"
  end
end
