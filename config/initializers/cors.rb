# Be sure to restart your server when you modify this file.

# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Secure origin validation for production
    origins do |origin|
      # Return nil if origin is missing (shouldn't happen, but be safe)
      return false if origin.blank?
      
      # Parse the origin to validate format
      begin
        uri = URI.parse(origin)
        # Only allow http/https schemes
        return false unless ['http', 'https'].include?(uri.scheme)
      rescue URI::InvalidURIError
        return false
      end
      
      if Rails.env.development?
        # Development: Allow localhost and 127.0.0.1 on any port
        # This covers common dev ports: 3000, 5173, 8080, etc.
        origin.match?(/\Ahttps?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0)(:\d+)?\/?\z/) ||
        origin.match?(/\Ahttps?:\/\/\[::1\](:\d+)?\/?\z/) # IPv6 localhost
      elsif Rails.env.test?
        # Test environment: Allow localhost only
        origin.match?(/\Ahttps?:\/\/(localhost|127\.0\.0\.1)(:\d+)?\z/)
      else
        # Production/Staging: Only allow explicitly configured origins
        # Get allowed origins from environment variable
        # Format: "https://example.com,https://www.example.com,https://app.example.com"
        allowed_origins = ENV.fetch('ALLOWED_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)
        
        # In production, ALLOWED_ORIGINS must be set
        if allowed_origins.empty?
          Rails.logger.error "[CORS] ALLOWED_ORIGINS not configured in production! This is a security risk."
          return false
        end
        
        # Check if origin matches any allowed origin (exact match for security)
        allowed_origins.include?(origin)
      end
    end
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'X-CSRF-Token', 'Content-Type', 'Set-Cookie'],
      credentials: true, # Enable credentials to support cookies and auth tokens
      max_age: 86400 # Cache preflight requests for 24 hours
  end
end

