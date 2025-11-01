# Environment Variables Configuration
# This file loads and validates all environment variables

Rails.application.configure do
  # ===========================================
  # REQUIRED ENVIRONMENT VARIABLES
  # ===========================================
  required_vars = %w[
    SECRET_KEY_BASE
    JWT_SECRET_KEY
    SMTP_USERNAME
    SMTP_PASSWORD
    MAILER_FROM_EMAIL
  ]

  # Check for required variables in production
  if Rails.env.production?
    missing_vars = required_vars.select { |var| ENV[var].blank? }
    
    if missing_vars.any?
      raise "Missing required environment variables: #{missing_vars.join(', ')}"
    end
  end

  # ===========================================
  # APPLICATION CONFIGURATION
  # ===========================================
  config.host = ENV.fetch('HOST', 'localhost')
  config.port = ENV.fetch('PORT', 3000).to_i

  # ===========================================
  # JWT CONFIGURATION
  # ===========================================
  config.jwt_secret_key = ENV.fetch('JWT_SECRET_KEY', 'development_jwt_secret_key')
  config.jwt_algorithm = ENV.fetch('JWT_ALGORITHM', 'HS256')
  config.jwt_expiration_time = ENV.fetch('JWT_EXPIRATION_TIME', '24h')

  # ===========================================
  # EMAIL CONFIGURATION
  # ===========================================
  config.mailer_from_email = ENV.fetch('MAILER_FROM_EMAIL', 'noreply@luxethreads.com')
  config.mailer_from_name = ENV.fetch('MAILER_FROM_NAME', 'LuxeThreads')
  config.support_email = ENV.fetch('SUPPORT_EMAIL', 'support@luxethreads.com')

  # ===========================================
  # EMAIL VERIFICATION CONFIGURATION
  # ===========================================
  config.otp_expiry_minutes = ENV.fetch('OTP_EXPIRY_MINUTES', 15).to_i
  config.otp_length = ENV.fetch('OTP_LENGTH', 6).to_i
  config.max_otp_attempts = ENV.fetch('MAX_OTP_ATTEMPTS', 3).to_i
  config.otp_resend_cooldown_minutes = ENV.fetch('OTP_RESEND_COOLDOWN_MINUTES', 1).to_i

  # ===========================================
  # ADMIN CONFIGURATION
  # ===========================================
  config.admin_session_timeout = ENV.fetch('ADMIN_SESSION_TIMEOUT', '8h')
  config.admin_max_login_attempts = ENV.fetch('ADMIN_MAX_LOGIN_ATTEMPTS', 5).to_i
  config.admin_lockout_duration = ENV.fetch('ADMIN_LOCKOUT_DURATION', '30m')

  # ===========================================
  # SECURITY CONFIGURATION
  # ===========================================
  config.allowed_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3000').split(',')
  config.rate_limit_requests_per_minute = ENV.fetch('RATE_LIMIT_REQUESTS_PER_MINUTE', 60).to_i
  config.rate_limit_burst = ENV.fetch('RATE_LIMIT_BURST', 100).to_i

  # ===========================================
  # FILE UPLOAD CONFIGURATION
  # ===========================================
  config.max_file_size = ENV.fetch('MAX_FILE_SIZE', '10MB')
  config.allowed_file_types = ENV.fetch('ALLOWED_FILE_TYPES', 'jpg,jpeg,png,gif,pdf,doc,docx').split(',')

  # ===========================================
  # DEVELOPMENT FLAGS
  # ===========================================
  config.skip_email_verification_in_dev = ENV.fetch('SKIP_EMAIL_VERIFICATION_IN_DEV', 'false') == 'true'
  config.log_emails_to_console = ENV.fetch('LOG_EMAILS_TO_CONSOLE', 'true') == 'true'
end

# ===========================================
# CLOUDINARY CONFIGURATION
# ===========================================
if ENV['CLOUDINARY_CLOUD_NAME'].present?
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
    config.secure = true
    config.cdn_subdomain = true
  end
end

# ===========================================
# STRIPE CONFIGURATION
# ===========================================
if ENV['STRIPE_SECRET_KEY'].present?
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  Stripe.api_version = '2023-10-16'
end

# ===========================================
# SENTRY CONFIGURATION (Error Tracking)
# ===========================================

if ENV['SENTRY_DSN'].present? && defined?(Sentry)
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.1
    config.profiles_sample_rate = 0.1
  end
end



