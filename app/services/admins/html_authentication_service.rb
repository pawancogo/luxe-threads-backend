# frozen_string_literal: true

# Service for authenticating admins via HTML interface (session-based)
module Admins
  class HtmlAuthenticationService < BaseService
    attr_reader :admin

    def initialize(email, password, request, session_id)
      super()
      @email = email
      @password = password
      @request = request
      @session_id = session_id
    end

    def call
      find_admin
      return self unless @admin

      validate_authentication
      return self if failure?

      check_account_status
      return self if failure?

      authenticate_admin
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def find_admin
      @admin = Admin.find_by(email: @email)
      unless @admin
        add_error('Invalid email or password')
        log_failed_attempt(nil, 'Admin not found')
      end
    end

    def validate_authentication
      return if @admin.nil?

      unless @admin.authenticate(@password)
        add_error('Invalid email or password')
        log_failed_attempt(@admin, 'Invalid password')
      end
    end

    def check_account_status
      return if @admin.nil? || failure?

      # Check if admin is blocked
      if @admin.is_blocked?
        add_error('Your account has been blocked. Please contact the administrator.')
        return
      end

      # Check if admin is inactive
      unless @admin.is_active
        handle_inactive_account
        return
      end
    end

    def handle_inactive_account
      # If email is not verified, send verification email
      unless @admin.email_verified?
        unless @admin.email_verifications.pending.active.exists?
          Authentication::EmailVerificationService.new(@admin).send_verification_email
        end
        add_error('Your account is inactive. Please verify your email to activate your account.')
        set_result({
          error_code: 'ACCOUNT_INACTIVE',
          requires_verification: true,
          verification_url: "/verify-email?type=admin&id=#{@admin.id}&email=#{CGI.escape(@admin.email)}&reason=inactive"
        })
      else
        add_error('Your account is inactive. Please contact the administrator to activate your account.')
      end
    end

    def authenticate_admin
      return if failure?

      # Update last login
      @admin.update_last_login!

      # Create login session
      Authentication::SessionService.create_session(
        @admin,
        @request,
        {
          login_method: 'password',
          platform: 'web',
          jwt_token_id: "session_#{@session_id}"
        }
      )

      # Log admin activity
      AdminActivity.log_activity(
        @admin,
        'login',
        nil,
        nil,
        {
          description: 'Admin logged in via HTML interface',
          ip_address: @request.remote_ip,
          user_agent: @request.user_agent
        }
      )

      set_result({ admin: @admin })
    end

    def log_failed_attempt(admin, reason)
      return unless admin

      Authentication::SessionService.create_session(
        admin,
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

