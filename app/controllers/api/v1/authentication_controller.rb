class Api::V1::AuthenticationController < ApplicationController
  include JsonWebToken
  skip_before_action :authenticate_request, only: [:create]
  skip_before_action :authenticate_request, only: [:destroy], if: -> { request.method == 'DELETE' }

  # POST /api/v1/login
  def create
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      # Check if user is inactive (soft deleted)
      if @user.deleted_at.present?
        # Send verification OTP if not already sent
        unless @user.email_verifications.pending.active.exists?
          EmailVerificationService.new(@user).send_verification_email
        end
        
        render json: {
          success: false,
          message: 'Your account has been deactivated. Please verify your account to reactivate.',
          error_code: 'ACCOUNT_INACTIVE',
          requires_verification: true,
          verification_url: "/verify-email?type=user&id=#{@user.id}&email=#{CGI.escape(@user.email)}&reason=inactive"
        }, status: :unauthorized
        return
      end
      
      # Check if email is not verified
      unless @user.email_verified?
        # Send verification OTP if not already sent
        unless @user.email_verifications.pending.active.exists?
          EmailVerificationService.new(@user).send_verification_email
        end
        
        render json: {
          success: false,
          message: 'Please verify your email address to continue.',
          error_code: 'EMAIL_NOT_VERIFIED',
          requires_verification: true,
          verification_url: "/verify-email?type=user&id=#{@user.id}&email=#{CGI.escape(@user.email)}"
        }, status: :unauthorized
        return
      end
      
      token = jwt_encode({ user_id: @user.id })
      
      # Update last login
      @user.update_column(:last_login_at, Time.current) if @user.respond_to?(:last_login_at)
      
      # Create login session with device and location info
      LoginSessionService.create_session(
        @user,
        request,
        {
          login_method: 'password',
          screen_resolution: params[:screen_resolution],
          viewport_size: params[:viewport_size],
          connection_type: params[:connection_type],
          platform: params[:platform] || 'web',
          app_version: params[:app_version]
        }
      )
      
      # Set httpOnly cookie for token
      cookies.signed[:auth_token] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: 7.days.from_now
      }
      
      user_data = {
        id: @user.id,
        email: @user.email,
        role: @user.role,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email_verified: @user.email_verified?,
        is_active: @user.deleted_at.nil?
      }
      render_success({ user: user_data }, 'Login successful')
    else
      # Log failed login attempt
      if @user
        LoginSessionService.create_session(
          @user,
          request,
          {
            login_method: 'password',
            is_successful: false,
            failure_reason: 'Invalid password'
          }
        )
      end
      render_unauthorized('Invalid email or password')
    end
  end

  # DELETE /api/v1/logout
  def destroy
    # Clear the auth cookie
    cookies.delete(:auth_token, domain: :all)
    
    # Optionally mark login session as logged out
    if @current_user
      LoginSession.for_user(@current_user)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(logged_out_at: Time.current, is_active: false)
    end
    
    render_success({}, 'Logged out successfully')
  end
end