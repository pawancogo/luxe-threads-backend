# frozen_string_literal: true

# Service for authenticating users
module Users
  class AuthenticationService < BaseService
    include JsonWebToken
    
    attr_reader :user, :token, :user_data

    def initialize(email, password, request, session_params = {})
      super()
      @email = email
      @password = password
      @request = request
      @session_params = session_params
    end

    def call
      find_user
      return self unless @user

      validate_authentication
      return self if failure?

      check_account_status
      return self if failure?

      authenticate_user
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def find_user
      @user = User.find_by(email: @email)
      unless @user
        add_error('Invalid email or password')
        log_failed_attempt(nil, 'User not found')
      end
    end

    def validate_authentication
      return if @user.nil?

      unless @user.authenticate(@password)
        add_error('Invalid email or password')
        log_failed_attempt(@user, 'Invalid password')
      end
    end

    def check_account_status
      return if @user.nil? || failure?

      # Check if account is deactivated
      if @user.deleted_at.present?
        handle_inactive_account
        return
      end

      # Check if email is not verified
      unless @user.email_verified?
        handle_unverified_email
        return
      end
    end

    def handle_inactive_account
      # Send verification email if not already sent
      unless @user.email_verifications.pending.active.exists?
        Authentication::EmailVerificationService.new(@user).send_verification_email
      end

      add_error('Your account has been deactivated. Please verify your account to reactivate.')
      set_result({
        error_code: 'ACCOUNT_INACTIVE',
        requires_verification: true,
        verification_url: "/verify-email?type=user&id=#{@user.id}&email=#{CGI.escape(@user.email)}&reason=inactive"
      })
    end

    def handle_unverified_email
      # Send verification email if not already sent
      unless @user.email_verifications.pending.active.exists?
        Authentication::EmailVerificationService.new(@user).send_verification_email
      end

      add_error('Please verify your email address to continue.')
      set_result({
        error_code: 'EMAIL_NOT_VERIFIED',
        requires_verification: true,
        verification_url: "/verify-email?type=user&id=#{@user.id}&email=#{CGI.escape(@user.email)}"
      })
    end

    def authenticate_user
      return if failure?

      # Generate JWT token
      @token = jwt_encode({ user_id: @user.id })

      # Update last login timestamp
      # NOTE: Using update_column for timestamp tracking only (no validations/callbacks needed)
      # This is acceptable for performance-critical timestamp updates
      @user.update_column(:last_login_at, Time.current) if @user.respond_to?(:last_login_at)

      # Create login session
      Authentication::SessionService.create_session(
        @user,
        @request,
        @session_params.merge(
          login_method: 'password',
          platform: @session_params[:platform] || 'web'
        )
      )

      # Prepare user data
      @user_data = {
        id: @user.id,
        email: @user.email,
        role: @user.role,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email_verified: @user.email_verified?,
        is_active: @user.deleted_at.nil?
      }

      set_result({ user: @user_data, token: @token })
    end

    def log_failed_attempt(user, reason)
      return unless user

      Authentication::SessionService.create_session(
        user,
        @request,
        {
          login_method: 'password',
          is_successful: false,
          failure_reason: reason
        }
      )
    end
  end
end

