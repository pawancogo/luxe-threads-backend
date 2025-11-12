require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.variant_processor = :mini_magick
  config.active_storage.service = :local

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  
  # Enable asset pipeline for RailsAdmin
  config.assets.enabled = true
  config.assets.compile = true
  config.assets.debug = false

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # ===========================================
  # EMAIL CONFIGURATION
  # ===========================================
  config.action_mailer.default_url_options = {
    host: ENV.fetch('HOST', 'localhost'),
    port: ENV.fetch('PORT', 3000)
  }

  # SMTP Configuration - Direct configuration with environment variable fallback
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  
  # Get SMTP settings from environment variables or use defaults
  smtp_address = ENV.fetch('SMTP_ADDRESS', 'smtp.gmail.com')
  smtp_port = ENV.fetch('SMTP_PORT', '587').to_i
  smtp_domain = ENV.fetch('SMTP_DOMAIN', 'gmail.com')
  smtp_username = ENV.fetch('SMTP_USERNAME', 'pawancogoport@gmail.com')
  smtp_password = ENV.fetch('SMTP_PASSWORD', 'taiaxcmahjoqoveo')
  smtp_authentication = ENV.fetch('SMTP_AUTHENTICATION', 'plain')
  # For development, use 'none' to avoid SSL certificate verification issues
  # For production, use 'peer' for proper certificate verification
  smtp_openssl_verify_mode = ENV.fetch('SMTP_OPENSSL_VERIFY_MODE', 'none')
  
  config.action_mailer.smtp_settings = {
    address: smtp_address,
    port: smtp_port,
    domain: smtp_domain,
    user_name: smtp_username,
    password: smtp_password,
    authentication: smtp_authentication,
    enable_starttls_auto: true,
    openssl_verify_mode: smtp_openssl_verify_mode
  }
  
  # Debug logging (safe check for Rails.logger availability)
  if defined?(Rails) && Rails.logger
    Rails.logger.info "=" * 60
    Rails.logger.info "SMTP Configuration Applied:"
    Rails.logger.info "  raise_delivery_errors: #{config.action_mailer.raise_delivery_errors}"
    Rails.logger.info "  perform_deliveries: #{config.action_mailer.perform_deliveries}"
    Rails.logger.info "  delivery_method: #{config.action_mailer.delivery_method}"
    Rails.logger.info "  smtp_settings.address: #{config.action_mailer.smtp_settings[:address]}"
    Rails.logger.info "  smtp_settings.port: #{config.action_mailer.smtp_settings[:port]}"
    Rails.logger.info "  smtp_settings.domain: #{config.action_mailer.smtp_settings[:domain]}"
    Rails.logger.info "  smtp_settings.user_name: #{config.action_mailer.smtp_settings[:user_name]}"
    Rails.logger.info "  smtp_settings.password: #{smtp_password.present? ? '[SET - ' + smtp_password.length.to_s + ' chars]' : '[NOT SET]'}"
    Rails.logger.info "  smtp_settings.authentication: #{config.action_mailer.smtp_settings[:authentication]}"
    Rails.logger.info "  smtp_settings.enable_starttls_auto: #{config.action_mailer.smtp_settings[:enable_starttls_auto]}"
    Rails.logger.info "  smtp_settings.openssl_verify_mode: #{config.action_mailer.smtp_settings[:openssl_verify_mode]}"
    Rails.logger.info "=" * 60
  end
  
  # Verify configuration after Rails is fully loaded
  Rails.application.config.to_prepare do
    if Rails.env.development?
      Rails.logger.info "🔍 Verifying SMTP Configuration at Runtime:"
      Rails.logger.info "  ActionMailer::Base.delivery_method: #{ActionMailer::Base.delivery_method}"
      Rails.logger.info "  ActionMailer::Base.perform_deliveries: #{ActionMailer::Base.perform_deliveries}"
      Rails.logger.info "  ActionMailer::Base.raise_delivery_errors: #{ActionMailer::Base.raise_delivery_errors}"
      Rails.logger.info "  ActionMailer::Base.smtp_settings: #{ActionMailer::Base.smtp_settings.inspect}"
    end
  end

  # ===========================================
  # SECURITY CONFIGURATION
  # ===========================================
  # CORS Configuration is handled in config/initializers/cors.rb
  # No need to duplicate here

  # ===========================================
  # LOGGING CONFIGURATION
  # ===========================================
  config.log_level = ENV.fetch('LOG_LEVEL', 'debug').to_sym
end

