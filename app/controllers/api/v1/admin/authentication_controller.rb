# frozen_string_literal: true

module Api::V1::Admin
  class AuthenticationController < ApplicationController
    include JsonWebToken
    skip_before_action :authenticate_request
    
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
        
        admin_data = {
          id: @admin.id,
          email: @admin.email,
          role: @admin.role,
          first_name: @admin.first_name,
          last_name: @admin.last_name,
          full_name: @admin.full_name,
          permissions: @admin.permissions_hash
        }
        
        render_success({ token: token, admin: admin_data }, 'Admin login successful')
      else
        render_unauthorized('Invalid email or password')
      end
    end
  end
end

