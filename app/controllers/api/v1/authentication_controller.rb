class Api::V1::AuthenticationController < ApplicationController
  include JsonWebToken
  skip_before_action :authenticate_request, only: [:create]
  skip_before_action :authenticate_request, only: [:destroy], if: -> { request.method == 'DELETE' }

  # POST /api/v1/login
  def create
    service = Users::AuthenticationService.new(
      params[:email],
      params[:password],
      request,
      {
        screen_resolution: params[:screen_resolution],
        viewport_size: params[:viewport_size],
        connection_type: params[:connection_type],
        platform: params[:platform] || 'web',
        app_version: params[:app_version]
      }
    )
    service.call
    
    if service.success?
      # Set httpOnly cookie for token
      cookies.signed[:auth_token] = {
        value: service.token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: 7.days.from_now
      }
      
      render_success(service.result, 'Login successful')
    else
      # Check if there's a special result (for inactive/unverified accounts)
      if service.result.is_a?(Hash) && service.result[:error_code]
        render json: {
          success: false,
          message: service.errors.first,
          error_code: service.result[:error_code],
          requires_verification: service.result[:requires_verification],
          verification_url: service.result[:verification_url]
        }, status: :unauthorized
      else
        render_unauthorized(service.errors.first || 'Invalid email or password')
      end
    end
  end

  # DELETE /api/v1/logout
  def destroy
    # Clear the auth cookie
    cookies.delete(:auth_token, domain: :all)
    
    # Mark login session as logged out
    if @current_user
      service = Users::LogoutService.new(@current_user)
      service.call
    end
    
    render_success({}, 'Logged out successfully')
  end
end