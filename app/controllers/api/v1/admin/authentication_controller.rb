# frozen_string_literal: true

module Api::V1::Admin
  class AuthenticationController < ApplicationController
    include JsonWebToken
    skip_before_action :authenticate_request
    skip_before_action :authenticate_admin_request, only: [:create, :destroy, :me]
    before_action :authenticate_admin_request, only: [:me]
    
    # POST /api/v1/admin/login
    def create
      service = Admins::AuthenticationService.new(
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
        # Set httpOnly cookie for admin token
        cookies.signed[:admin_token] = {
          value: service.token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 24.hours.from_now
        }
        
        render_success(service.result, 'Admin login successful')
      else
        # Check if there's a special result (for inactive accounts)
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
    
    # DELETE /api/v1/admin/logout
    def destroy
      # Try to get admin from token before clearing cookie
      token = cookies.signed[:admin_token] || cookies[:admin_token] || request.headers['Authorization']&.split(' ')&.last
      admin = nil
      
      if token
        begin
          decoded = jwt_decode(token)
          admin = Admin.find_by(id: decoded[:admin_id]) if decoded[:admin_id]
        rescue
          # Token invalid, continue with logout
        end
      end
      
      # Clear the admin cookie
      cookies.delete(:admin_token, domain: :all)
      
      # Mark login session as logged out
      if admin
        service = Admins::LogoutService.new(admin, request)
        service.call
      end
      
      render_success({}, 'Admin logged out successfully')
    end
    
    # GET /api/v1/admin/me
    def me
      if @current_admin
        admin_data = {
          id: @current_admin.id,
          email: @current_admin.email,
          role: @current_admin.role,
          first_name: @current_admin.first_name,
          last_name: @current_admin.last_name,
          full_name: @current_admin.full_name,
          permissions: @current_admin.permissions_hash
        }
        render_success({ admin: admin_data }, 'Admin data retrieved successfully')
      else
        render_unauthorized('Not authenticated')
      end
    end
  end
end

