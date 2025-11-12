# frozen_string_literal: true

# Enhanced health check controller for Docker/Kubernetes
# Extends Rails 7.1+ built-in health check with database and Redis checks
module Rails
  class HealthController < ActionController::Base
    def show
      # Check database connection
      db_status = check_database
      
      # Check Redis if available
      redis_status = check_redis
      
      # Determine overall status
      status = (db_status == "ok") ? 200 : 503
      
      render json: {
        status: status == 200 ? "healthy" : "unhealthy",
        timestamp: Time.current.iso8601,
        checks: {
          database: db_status,
          redis: redis_status
        }
      }, status: status
    end
    
    private
    
    def check_database
      ActiveRecord::Base.connection.execute("SELECT 1")
      "ok"
    rescue => e
      "error: #{e.message}"
    end
    
    def check_redis
      if defined?(Redis) && ENV['REDIS_URL'].present?
        redis = Redis.new(url: ENV['REDIS_URL'])
        redis.ping
        "ok"
      else
        "not_configured"
      end
    rescue => e
      "error: #{e.message}"
    end
  end
end





