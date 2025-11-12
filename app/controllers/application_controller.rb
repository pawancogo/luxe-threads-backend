class ApplicationController < ActionController::API
  include ActionController::Cookies
  include JsonWebToken
  include ApiResponder
  include Pundit::Authorization
  include FeatureFlagHelper

  # Skip authentication for OPTIONS requests (CORS preflight)
  before_action :authenticate_request, unless: -> { request.method == 'OPTIONS' }
  
  # Handle database constraint errors globally
  # Note: Skip rescue_from for RecordNotUnique in controllers that handle it explicitly
  # to avoid double handling. Use handle_statement_invalid for StatementInvalid.
  rescue_from ActiveRecord::StatementInvalid, with: :handle_statement_invalid
  # Handle routing errors (404)
  rescue_from ActionController::RoutingError, with: :route_not_found
  
  # Override Pundit's user method to use current_user
  def pundit_user
    current_user
  end

  private

  def authenticate_request
    # Allow public endpoints to skip authentication
    # Note: Controllers can use skip_before_action to override this
    public_paths = [
      '/api/v1/public/products',
      '/api/v1/categories',
      '/api/v1/brands',
      '/api/v1/attribute_types',
      '/api/v1/search',
      '/api/v1/signup',
      '/api/v1/login',
      '/api/v1/password/forgot',
      '/api/v1/password/reset'
    ]
    
    # Check if this is a public endpoint
    is_public_path = public_paths.any? { |path| request.path.start_with?(path) }
    
    if is_public_path
      return
    end
    
    # Try cookie first (httpOnly, more secure), then Authorization header (backward compatibility)
    token = cookies.signed[:auth_token] || cookies[:auth_token]
    token ||= request.headers['Authorization']&.split(' ')&.last
    
    unless token
      render_unauthorized('Authentication token missing')
      return
    end
    
    begin
      @decoded = jwt_decode(token)
      @current_user = User.find(@decoded[:user_id])
      
      # Check if user is inactive (soft deleted)
      if @current_user.deleted_at.present?
        # Clear token cookie
        cookies.delete(:auth_token, domain: :all)
        
        # Return specific error for inactive account
        render json: {
          success: false,
          message: 'Your account has been deactivated. Please verify your account to reactivate.',
          error_code: 'ACCOUNT_INACTIVE',
          requires_verification: true
        }, status: :unauthorized
        return
      end
      
      # Allow unverified users to access certain endpoints (user profile, email verification, supplier profile)
      # This allows them to check their status, verify their email, and create supplier profile
      allowed_unverified_paths = [
        '/api/v1/users/me',
        '/api/v1/email',
        '/api/v1/email/verify',
        '/api/v1/email/resend',
        '/api/v1/email/resend_authenticated',
        '/api/v1/email/status',
        '/api/v1/supplier_profile' # Allow suppliers to create/update profile even if email not verified
      ]
      
      is_allowed_unverified_path = allowed_unverified_paths.any? { |path| request.path.start_with?(path) }
      
      # Check if email is not verified (but allow access to verification endpoints)
      unless @current_user.email_verified? || is_allowed_unverified_path
        render json: {
          success: false,
          message: 'Please verify your email address to continue.',
          error_code: 'EMAIL_NOT_VERIFIED',
          requires_verification: true,
          verification_url: "/verify-email?type=user&id=#{@current_user.id}&email=#{CGI.escape(@current_user.email)}"
        }, status: :unauthorized
        return
      end
    rescue ActiveRecord::RecordNotFound => e
      # User might be soft deleted or doesn't exist
      if e.message.include?('deleted_at')
        render_unauthorized('User account has been deactivated')
      else
        render_unauthorized('Invalid authentication token')
      end
    rescue JWT::ExpiredSignature => e
      render_unauthorized('Authentication token has expired. Please login again.')
    rescue JWT::DecodeError => e
      render_unauthorized('Invalid authentication token')
    end
  end

  def handle_statement_invalid(error)
    message = error.message.to_s.downcase
    # Check if it's a constraint error
    if message.include?('unique constraint') || 
       message.include?('foreign key constraint') ||
       message.include?('not null constraint') ||
       (message.include?('constraint') && !message.include?('check constraint'))
      handle_constraint_error(error)
    else
      # For other SQL errors, log and return generic error with trace in dev
      Rails.logger.error "SQL Error: #{error.class} - #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      render_server_error('Database error occurred', error)
    end
  end

  def route_not_found
    render json: { 
      error: 'Route not found', 
      message: 'The requested route does not exist',
      path: request.path
    }, status: :not_found
  end

  attr_reader :current_user
end
