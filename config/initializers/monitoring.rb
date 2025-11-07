# frozen_string_literal: true

# Monitoring and Logging Configuration

# Application performance monitoring
if ENV['APM_ENABLED'] == 'true'
  # Configure APM (e.g., New Relic, Datadog, AppSignal)
  # Example with New Relic:
  # require 'newrelic_rpm'
end

# Error tracking (Sentry recommended)
if ENV['SENTRY_DSN'].present?
  begin
    require 'sentry-ruby'
    
    Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', 0.1).to_f
    config.environment = Rails.env
    config.release = ENV['APP_VERSION'] || 'unknown'
    
    # Filter sensitive data
    config.before_send = lambda do |event, hint|
      # Remove sensitive data from event
      event.request.data&.delete('password')
      event.request.data&.delete('password_confirmation')
      event.request.data&.delete('token')
      event
    end
  end
  rescue LoadError
    Rails.logger.warn "Sentry gem not installed. Skipping Sentry initialization."
  end
end

# Logging configuration
Rails.application.configure do
  # Structured logging for production
  if Rails.env.production?
    config.log_formatter = ActiveSupport::Logger::SimpleFormatter.new
    config.logger = ActiveSupport::Logger.new(
      Rails.root.join("log", "#{Rails.env}.log"),
      "daily",
      10.megabytes
    )
  end
end

# Custom logging helpers
module ApplicationLogger
  def self.log_info(message, context = {})
    Rails.logger.info({
      message: message,
      timestamp: Time.current.iso8601,
      context: context
    }.to_json)
  end
  
  def self.log_error(message, error = nil, context = {})
    log_data = {
      message: message,
      timestamp: Time.current.iso8601,
      context: context
    }
    
    if error
      log_data[:error] = {
        class: error.class.name,
        message: error.message,
        backtrace: error.backtrace&.first(5)
      }
    end
    
    Rails.logger.error(log_data.to_json)
    
    # Send to error tracking
    Sentry.capture_exception(error) if defined?(Sentry) && error
  end
  
  def self.log_performance(operation, duration_ms, context = {})
    Rails.logger.info({
      type: 'performance',
      operation: operation,
      duration_ms: duration_ms,
      timestamp: Time.current.iso8601,
      context: context
    }.to_json)
  end
end

# Performance monitoring middleware
class PerformanceMonitoring
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start_time = Time.current
    status, headers, response = @app.call(env)
    duration = ((Time.current - start_time) * 1000).round(2)
    
    # Log slow requests
    if duration > 1000 # 1 second
      ApplicationLogger.log_performance(
        "#{env['REQUEST_METHOD']} #{env['PATH_INFO']}",
        duration,
        { status: status }
      )
    end
    
    [status, headers, response]
  end
end

# Add middleware in production
if Rails.env.production?
  Rails.application.middleware.use PerformanceMonitoring
end

