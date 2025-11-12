# frozen_string_literal: true

# Service for handling email verification flow
# Handles OTP generation, sending, and verification
module Authentication
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
        deliver_verification_email(verification)
        true
      else
        send_verification_email.present?
      end
    end

    def verify_email_with_token(token)
      verification = find_active_verification
      
      return failure_response('No pending verification found') unless verification
      return failure_response('Verification link has expired') if verification.expired?
      return failure_response('Verification already completed') if verification.verified?
      
      # Validate token
      return failure_response('Invalid verification link') unless valid_token?(verification, token)
      
      # Perform verification
      ActiveRecord::Base.transaction do
        mark_verification_as_verified(verification)
        update_verifiable_attributes
      end
      
      success_response
    rescue StandardError => e
      Rails.logger.error "Email verification failed: #{e.message}"
      failure_response('Verification failed. Please try again.')
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
      deliver_verification_email(verification)
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

    def deliver_verification_email(verification)
      Rails.logger.info "Attempting to send verification email to #{verification.email}"
      
      success = EmailDeliveryService.deliver(-> { EmailVerificationMailer.send_verification(verification) })
      
      return true if success

      fallback_in_development(verification)
    end

    def fallback_in_development(verification)
      return false unless Rails.env.development?

      log_verification_to_console(verification)
      true
    end

    def log_verification_to_console(verification)
      expires_at = verification.created_at + 24.hours
      
      Rails.logger.info '=' * 50
      Rails.logger.info 'EMAIL VERIFICATION (DEVELOPMENT)'
      Rails.logger.info '=' * 50
      Rails.logger.info "To: #{verification.email}"
      Rails.logger.info "Token: #{verification.verification_token}"
      Rails.logger.info "Expires: #{expires_at}"
      Rails.logger.info "Verification URL: #{verification_url(verification)}"
      Rails.logger.info '=' * 50
    end

    def verification_url(verification)
      verifiable = verification.verifiable
      
      # For admins, use backend URL (they use HTML interface)
      if verifiable.is_a?(Admin)
        base_url = build_backend_url
      else
        # For users and suppliers, use frontend URL (they use React app)
        base_url = build_frontend_url
      end
      
      params = build_verification_params(verification)
      "#{base_url}/verify-email?#{params}"
    end

    def build_backend_url
      config = Rails.application.config
      protocol = Rails.env.production? ? 'https' : 'http'
      port = Rails.env.production? ? '' : ":#{config.port}"
      "#{protocol}://#{config.host}#{port}"
    end

    def build_frontend_url
      Rails.application.config.frontend_url || 'http://localhost:8080'
    end

    def build_verification_params(verification)
      {
        token: verification.verification_token
      }.to_query
    end

    def valid_token?(verification, token)
      return false if verification.verification_token.blank? || token.blank?
      ActiveSupport::SecurityUtils.secure_compare(verification.verification_token, token)
    end

    def mark_verification_as_verified(verification)
      verification.update!(verified_at: Time.current)
    end

    def update_verifiable_attributes
      # Update email_verified flag
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
    end
  end
end

