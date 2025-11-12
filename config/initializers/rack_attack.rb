# frozen_string_literal: true

# Rate limiting configuration for API protection
class Rack::Attack
  # Enable rack attack
  enabled = true

  # Allow requests from localhost in development
  safelist('allow-localhost') do |req|
    Rails.env.development? && (req.ip == '127.0.0.1' || req.ip == '::1')
  end

  # Always allow OPTIONS requests (CORS preflight)
  safelist('allow-options') do |req|
    req.method == 'OPTIONS'
  end

  # Rate limit API requests by IP
  # Limit: 100 requests per minute per IP
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Rate limit authentication endpoints
  # Limit: 5 login attempts per 15 minutes per IP
  throttle('api/login', limit: 5, period: 15.minutes) do |req|
    req.ip if req.path == '/api/v1/login' && req.post?
  end

  # Rate limit signup endpoints
  # Limit: 10 signups per hour per IP
  throttle('api/signup', limit: 10, period: 1.hour) do |req|
    req.ip if req.path == '/api/v1/signup' && req.post?
  end

  # Rate limit password reset endpoints
  # Limit: 5 requests per hour per IP
  throttle('api/password-reset', limit: 5, period: 1.hour) do |req|
    req.ip if req.path.include?('forgot_password') || req.path.include?('reset_password')
  end

  # Rate limit by user ID (if authenticated)
  # Limit: 1000 requests per hour per user
  throttle('api/user', limit: 1000, period: 1.hour) do |req|
    # Extract user ID from JWT token if available
    if req.env['rack.attack.user_id']
      req.env['rack.attack.user_id']
    end
  end

  # Rate limit support ticket creation
  # Limit: 10 tickets per hour per IP
  throttle('api/support-tickets', limit: 10, period: 1.hour) do |req|
    req.ip if req.path.include?('/support_tickets') && req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    retry_after = match_data[:period] if match_data
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{
        success: false,
        message: 'Rate limit exceeded. Please try again later.',
        retry_after: retry_after
      }.to_json]
    ]
  end

  # Log blocked requests
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    if req.env['rack.attack.match_type'] == :throttle
      Rails.logger.warn "[Rack::Attack] Throttled #{req.env['rack.attack.match_type']} #{req.ip} #{req.path}"
    end
  end
end

