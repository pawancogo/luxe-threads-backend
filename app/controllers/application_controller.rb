class ApplicationController < ActionController::API
  include JsonWebToken
  include ApiResponder
  include Pundit::Authorization
  include FeatureFlagHelper

  before_action :authenticate_request
  
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
      
      # Check if email is not verified
      unless @current_user.email_verified?
        render json: {
          success: false,
          message: 'Please verify your email address to continue.',
          error_code: 'EMAIL_NOT_VERIFIED',
          requires_verification: true
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
