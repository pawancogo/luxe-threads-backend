# frozen_string_literal: true

class EmailDeliveryService
  ERROR_MAPPING = {
    Net::SMTPAuthenticationError => :authentication_failed,
    Net::SMTPFatalError => :recipient_invalid,
    Net::SMTPError => :smtp_error,
    Net::SMTPServerBusy => :server_busy,
    Net::SMTPUnknownError => :unknown_error,
    SocketError => :network_error
  }.freeze

  def self.deliver(mailer_action)
    mail = mailer_action.call
    mail.deliver_now
    Rails.logger.info "✓ Email sent successfully to #{mail.to}"
    true
  rescue *ERROR_MAPPING.keys => e
    handle_error(e, mailer_action)
    false
  rescue StandardError => e
    log_generic_error(e)
    false
  end

  private

  def self.handle_error(error, mailer_action)
    error_type = ERROR_MAPPING[error.class] || :unknown
    log_error(error_type, error)

    fallback_to_console if Rails.env.development?
  end

  def self.log_error(type, error)
    case type
    when :authentication_failed
      log_authentication_error(error)
    when :recipient_invalid
      Rails.logger.error "✗ SMTP Fatal Error: #{error.message}"
      Rails.logger.error 'Recipient email is invalid or rejected'
    else
      Rails.logger.error "✗ SMTP Error (#{type}): #{error.message}"
    end
  end

  def self.log_authentication_error(error)
    Rails.logger.error "✗ SMTP Authentication failed: #{error.message}"
    Rails.logger.error '=' * 60
    Rails.logger.error 'GMAIL SMTP AUTHENTICATION TROUBLESHOOTING:'
    Rails.logger.error '=' * 60
    Rails.logger.error '1. Use an App Password, NOT your regular Gmail password'
    Rails.logger.error '2. Generate App Password: https://myaccount.google.com/apppasswords'
    Rails.logger.error '3. Enable 2-Step Verification if not enabled'
    Rails.logger.error '4. Use full Gmail address as SMTP_USERNAME'
    Rails.logger.error '=' * 60
    Rails.logger.error "Username: #{ENV['SMTP_USERNAME'] || 'NOT SET'}"
    Rails.logger.error "Password: #{ENV['SMTP_PASSWORD'].present? ? 'SET (hidden)' : 'NOT SET'}"
    Rails.logger.error "Error: #{error.class} - #{error.message}"
    Rails.logger.error '=' * 60
  end

  def self.fallback_to_console
    Rails.logger.warn 'Falling back to console logging in development mode...'
  end

  def self.log_generic_error(error)
    Rails.logger.error "✗ Email delivery failed: #{error.class} - #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if error.backtrace
  end
end

