# frozen_string_literal: true

require_relative "production"

Rails.application.configure do
  # Staging-specific overrides
  config.force_ssl = false # Can be false in staging if needed
  config.log_level = :info
  
  # Staging database
  config.database_configuration = {
    staging: {
      adapter: "postgresql",
      encoding: "utf8",
      pool: 5,
      timeout: 5000,
      database: ENV.fetch("STAGING_DATABASE_NAME", "luxe_threads_staging"),
      username: ENV.fetch("STAGING_DATABASE_USER", "postgres"),
      password: ENV.fetch("STAGING_DATABASE_PASSWORD", ""),
      host: ENV.fetch("STAGING_DATABASE_HOST", "localhost"),
      port: ENV.fetch("STAGING_DATABASE_PORT", "5432")
    }
  }
  
  # Staging-specific email configuration
  config.action_mailer.default_url_options = { 
    host: ENV.fetch("STAGING_HOST", "staging.yourdomain.com"),
    protocol: "https"
  }
  
  # Enable all feature flags in staging for testing
  ENV['FEATURE_MULTI_USER_SUPPLIER_ACCOUNTS'] ||= 'true'
  ENV['FEATURE_NEW_PAYMENT_SYSTEM'] ||= 'true'
  ENV['FEATURE_ENHANCED_ANALYTICS'] ||= 'true'
  ENV['FEATURE_NEW_NOTIFICATION_SYSTEM'] ||= 'true'
  ENV['FEATURE_SUPPORT_TICKETS'] ||= 'true'
  ENV['FEATURE_LOYALTY_POINTS'] ||= 'true'
  ENV['FEATURE_PRODUCT_VIEWS_TRACKING'] ||= 'true'
  ENV['FEATURE_CACHING'] ||= 'true'
  
  # Staging-specific CORS
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins ENV.fetch('STAGING_FRONTEND_URL', 'https://staging-frontend.yourdomain.com')
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['Authorization'],
        credentials: true
    end
  end
  
  # Staging cache store (can use memory store for simplicity)
  config.cache_store = :memory_store, { size: 64.megabytes }
  
  # Enable detailed error pages in staging
  config.consider_all_requests_local = true
  config.action_controller.consider_all_requests_local = true
end

