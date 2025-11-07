# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory usage
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Enable server timing.
  config.server_timing = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redis-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.variant_processor = :mini_magick

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Log to STDOUT for production logging services
  config.log_to = %w[stdout]

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = "luxe_threads_production"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts << "example.com"
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.hosts_authorization = { exclude: ->(request) { request.path == "/up" } }

  # ===========================================
  # PRODUCTION-SPECIFIC CONFIGURATIONS
  # ===========================================
  
  # Production database configuration
  config.database_configuration = {
    production: {
      adapter: "postgresql",
      encoding: "utf8",
      pool: ENV.fetch("RAILS_MAX_THREADS", 5).to_i,
      timeout: 5000,
      database: ENV.fetch("DATABASE_NAME", "luxe_threads_production"),
      username: ENV.fetch("DATABASE_USER", "postgres"),
      password: ENV.fetch("DATABASE_PASSWORD", ""),
      host: ENV.fetch("DATABASE_HOST", "localhost"),
      port: ENV.fetch("DATABASE_PORT", "5432"),
      # Connection pool settings
      reaping_frequency: 10,
      # SSL for production
      sslmode: ENV.fetch("DATABASE_SSLMODE", "require")
    }
  }
  
  # Production cache store (Redis recommended)
  if ENV['REDIS_URL'].present?
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'],
      namespace: 'luxe_threads_cache',
      expires_in: 90.minutes,
      reconnect_attempts: 3
    }
  else
    # Fallback to memory store if Redis not available
    config.cache_store = :memory_store, { size: 128.megabytes }
  end
  
  # Production email configuration
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { 
    host: ENV.fetch("FRONTEND_URL", "yourdomain.com").gsub(/^https?:\/\//, ''),
    protocol: "https"
  }
  
  # SMTP configuration (use environment variables)
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    domain: ENV.fetch("SMTP_DOMAIN", "yourdomain.com"),
    user_name: ENV.fetch("SMTP_USERNAME", ""),
    password: ENV.fetch("SMTP_PASSWORD", ""),
    authentication: :plain,
    enable_starttls_auto: true
  }
  
  # Production CORS configuration
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins ENV.fetch('FRONTEND_URL', 'https://yourdomain.com').split(',')
      
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['Authorization'],
        credentials: true,
        max_age: 3600
    end
  end
  
  # Production logging
  if ENV['LOG_TO_FILE'].present?
    config.logger = ActiveSupport::Logger.new(
      Rails.root.join("log", "production.log"),
      "daily"
    )
    config.logger.formatter = config.log_formatter
    config.log_tags = [:request_id, :remote_ip]
  end
  
  # Error tracking (configure Sentry or similar)
  # config.sentry_dsn = ENV['SENTRY_DSN']
  
  # Background jobs (Sidekiq recommended)
  # config.active_job.queue_adapter = :sidekiq
  
  # Asset hosting (CDN)
  # config.action_controller.asset_host = ENV['CDN_URL']
  
  # Security headers
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'SAMEORIGIN',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
    'Referrer-Policy' => 'strict-origin-when-cross-origin'
  }
  
  # Rate limiting (already configured in rack_attack.rb)
  # Ensure Rack::Attack is enabled in production
  
  # Feature flags (controlled via environment variables)
  # See config/initializers/feature_flags.rb
end
