# frozen_string_literal: true

# Base JWT authentication concern
# Follows DRY principle - eliminates duplicate JWT handling
module JwtAuthentication
  extend ActiveSupport::Concern

  private

  # Extract and decode JWT token
  # Priority: 1. Cookie (httpOnly), 2. Authorization header (for backward compatibility)
  def extract_token
    # Try cookie first (more secure)
    token = cookies.signed[:auth_token] || cookies[:auth_token]
    return token if token.present?
    
    # Fallback to Authorization header
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end

  # Decode JWT token with error handling
  def decode_token(token)
    jwt_decode(token)
  rescue JWT::ExpiredSignature
    render_unauthorized('Authentication token has expired. Please login again.')
    nil
  rescue JWT::DecodeError
    render_unauthorized('Invalid authentication token')
    nil
  end

  # Validate token presence
  def validate_token_presence(token)
    unless token
      render_unauthorized('Authentication token missing')
      return false
    end
    true
  end

  # Handle authentication errors consistently
  def handle_auth_error(error)
    case error
    when ActiveRecord::RecordNotFound
      render_unauthorized('Invalid authentication token')
    when JWT::ExpiredSignature
      render_unauthorized('Authentication token has expired. Please login again.')
    when JWT::DecodeError
      render_unauthorized('Invalid authentication token')
    else
      render_unauthorized('Authentication failed')
    end
  end
end

