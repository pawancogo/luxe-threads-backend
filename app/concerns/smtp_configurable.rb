# frozen_string_literal: true

module SmtpConfigurable
  extend ActiveSupport::Concern

  class_methods do
    def configure_smtp(config, environment)
      return unless smtp_credentials_present?

      config.action_mailer.delivery_method = :smtp
      config.action_mailer.perform_deliveries = true
      config.action_mailer.raise_delivery_errors = environment == :production
      config.action_mailer.smtp_settings = build_smtp_settings

      log_smtp_configuration if environment == :development
    end

    private

    def build_smtp_settings
      {
        address: smtp_address,
        port: smtp_port,
        domain: smtp_domain,
        user_name: smtp_username,
        password: normalize_password(smtp_password),
        authentication: smtp_authentication.to_sym,
        enable_starttls_auto: starttls_enabled?,
        openssl_verify_mode: ssl_verify_mode
      }
    end

    def smtp_credentials_present?
      ENV['SMTP_USERNAME'].present? && ENV['SMTP_PASSWORD'].present?
    end

    def smtp_address
      ENV.fetch('SMTP_ADDRESS', default_smtp_address)
    end

    def smtp_port
      ENV.fetch('SMTP_PORT', '587').to_i
    end

    def smtp_domain
      ENV.fetch('SMTP_DOMAIN', extract_domain_from_address(smtp_address))
    end

    def smtp_username
      ENV.fetch('SMTP_USERNAME', '').strip
    end

    def smtp_password
      ENV.fetch('SMTP_PASSWORD', '').strip
    end

    def normalize_password(password)
      password.to_s.gsub(/\s+/, '')
    end

    def smtp_authentication
      ENV.fetch('SMTP_AUTHENTICATION', default_authentication).downcase
    end

    def default_authentication
      'plain'
    end

    def default_smtp_address
      Rails.env.production? ? 'smtp.sendgrid.net' : 'smtp.gmail.com'
    end

    def extract_domain_from_address(address)
      address.split('.').last(2).join('.')
    rescue
      'gmail.com'
    end

    def starttls_enabled?
      ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true'
    end

    def ssl_verify_mode
      ENV.fetch('SMTP_OPENSSL_VERIFY_MODE', 'none')
    end

    def log_smtp_configuration
      return unless Rails.logger

      Rails.logger.info '=' * 60
      Rails.logger.info 'SMTP Configuration:'
      Rails.logger.info "  Address: #{smtp_address}"
      Rails.logger.info "  Port: #{smtp_port}"
      Rails.logger.info "  Username: #{smtp_username}"
      Rails.logger.info "  Password: #{smtp_password.present? ? "[SET - #{normalize_password(smtp_password).length} chars]" : '[NOT SET]'}"
      Rails.logger.info "  Authentication: #{smtp_authentication}"
      Rails.logger.info "  STARTTLS: #{starttls_enabled?}"
      Rails.logger.info '=' * 60
    end
  end
end

