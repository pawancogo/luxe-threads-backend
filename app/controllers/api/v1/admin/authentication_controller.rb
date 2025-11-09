# frozen_string_literal: true

module Api::V1::Admin
  class AuthenticationController < ApplicationController
    include JsonWebToken
    skip_before_action :authenticate_request
    skip_before_action :authenticate_admin_request, only: [:create, :destroy, :me]
    before_action :authenticate_admin_request, only: [:me]
    
    # POST /api/v1/admin/login
    def create
      @admin = Admin.find_by(email: params[:email])
      
      unless @admin
        render_unauthorized('Invalid email or password')
        return
      end
      
      # Check if admin is active and not blocked
      unless @admin.is_active && !@admin.is_blocked
        render_unauthorized('Admin account is inactive or blocked')
        return
      end
      
      if @admin.authenticate(params[:password])
        # Generate JWT token with admin_id
        token = jwt_encode({ admin_id: @admin.id, type: 'admin' }, exp: 24.hours.from_now)
        
        # Update last login
        @admin.update_last_login!
        
        # Create login session with device and location info
        session = LoginSessionService.create_session(
          @admin,
          request,
          {
            login_method: 'password',
            screen_resolution: params[:screen_resolution],
            viewport_size: params[:viewport_size],
            connection_type: params[:connection_type],
            platform: params[:platform] || 'web',
            app_version: params[:app_version],
            jwt_token_id: token.split('.').first # Store first part of JWT for reference
          }
        )
        
        # Log admin activity
        AdminActivity.log_activity(
          @admin,
          'login',
          nil,
          nil,
          {
            description: 'Admin logged in via API',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          }
        )
        
        # Set httpOnly cookie for admin token (if using cookies for admin API)
        # Note: Admin API might use JWT in header, but we can also set cookie for consistency
        cookies.signed[:admin_token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 24.hours.from_now
        }
        
        admin_data = {
          id: @admin.id,
          email: @admin.email,
          role: @admin.role,
          first_name: @admin.first_name,
          last_name: @admin.last_name,
          full_name: @admin.full_name,
          permissions: @admin.permissions_hash
        }
        
        render_success({ admin: admin_data }, 'Admin login successful')
      else
        # Log failed login attempt
        LoginSessionService.create_session(
          @admin,
          request,
          {
            login_method: 'password',
            is_successful: false,
            failure_reason: 'Invalid password'
          }
        )
        render_unauthorized('Invalid email or password')
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
        LoginSession.for_user(admin)
                    .active
                    .where(logged_out_at: nil)
                    .update_all(logged_out_at: Time.current, is_active: false)
        
        # Log admin activity
        AdminActivity.log_activity(
          admin,
          'logout',
          nil,
          nil,
          {
            description: 'Admin logged out via API',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          }
        )
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

