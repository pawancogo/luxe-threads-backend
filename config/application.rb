require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LuxeThreads
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # ===========================================
    # API CONFIGURATION
    # ===========================================
    # Only return JSON responses for API controllers
    config.api_only = true

    # ===========================================
    # SECURITY CONFIGURATION
    # ===========================================
    # Enable CSRF protection for non-API requests
    config.force_ssl = Rails.env.production?

    # ===========================================
    # CORS CONFIGURATION
    # ===========================================
    # CORS will be configured in environment files

    # ===========================================
    # TIME ZONE CONFIGURATION
    # ===========================================
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # ===========================================
    # I18N CONFIGURATION
    # ===========================================
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en]

    # ===========================================
    # LOGGING CONFIGURATION
    # ===========================================
    config.log_level = Rails.env.production? ? :warn : :debug

    # ===========================================
    # ASSET CONFIGURATION
    # ===========================================
    # Disable asset pipeline for API-only app
    config.assets.enabled = false

    # ===========================================
    # SESSION CONFIGURATION
    # ===========================================
    # Configure session store for admin authentication
    config.session_store :cookie_store, 
      key: '_luxe_threads_session',
      secure: Rails.env.production?,
      httponly: true,
      same_site: :lax

    # ===========================================
    # CACHE CONFIGURATION
    # ===========================================
    # Cache configuration will be set in environment files

    # ===========================================
    # ACTIVE STORAGE CONFIGURATION
    # ===========================================
    # Active Storage will be configured for file uploads

    # ===========================================
    # ERROR HANDLING
    # ===========================================
    # Custom error pages
    config.exceptions_app = self.routes

    # ===========================================
    # GENERATORS CONFIGURATION
    # ===========================================
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # ===========================================
    # MIDDLEWARE CONFIGURATION
    # ===========================================
    # Add custom middleware if needed
    # config.middleware.use CustomMiddleware
    
    # Required middlewares for RailsAdmin
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, {key: "_luxe_threads_session", secure: false, httponly: true, same_site: :lax}

    # ===========================================
    # RAILS ADMIN CONFIGURATION
    # ===========================================
    # Rails Admin will be configured in initializer

    # ===========================================
    # DEVELOPMENT CONFIGURATION
    # ===========================================
    if Rails.env.development?
      # Enable better_errors for development
      # config.consider_all_requests_local = true
    end

    # ===========================================
    # PRODUCTION CONFIGURATION
    # ===========================================
    if Rails.env.production?
      # Production-specific configurations
      config.force_ssl = true
      config.consider_all_requests_local = false
    end
  end
end