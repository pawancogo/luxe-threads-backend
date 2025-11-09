# frozen_string_literal: true

module AdminAuthorization
  extend ActiveSupport::Concern
  include JwtAuthentication
  
  included do
    before_action :authenticate_admin_request, if: :admin_route?
    before_action :authorize_admin!, if: :admin_route?
  end
  
  private
  
  def admin_route?
    request.path.start_with?('/api/v1/admin')
  end
  
  def authenticate_admin_request
    # Skip authentication for logout endpoint
    return if action_name == 'destroy' && controller_name == 'authentication'
    
    token = extract_token
    return unless validate_token_presence(token)
    
    @decoded = decode_token(token)
    return unless @decoded
    
    unless valid_admin_token?(@decoded)
      render_unauthorized('Invalid authentication token type')
      return
    end
    
    load_and_validate_admin(@decoded[:admin_id])
  rescue StandardError => e
    handle_auth_error(e)
  end
  
  def valid_admin_token?(decoded)
    decoded[:type] == 'admin' && decoded[:admin_id].present?
  end
  
  def load_and_validate_admin(admin_id)
    @current_admin = Admin.find(admin_id)
    
    # Check if admin is blocked - if so, clear tokens and log out
    if @current_admin.is_blocked?
      # Clear admin token cookie (for API requests)
      cookies.delete(:admin_token, domain: :all)
      
      # Clear Rails session if it exists (for HTML requests)
      if session[:admin_id] == admin_id
        reset_session
      end
      
      # Mark all active login sessions as logged out
      LoginSession.for_user(@current_admin)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(logged_out_at: Time.current, is_active: false)
      
      # Log the forced logout
      AdminActivity.log_activity(
        @current_admin,
        'logout',
        nil,
        nil,
        {
          description: 'Admin automatically logged out due to account being blocked - all tokens and sessions cleared',
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
      
      render_unauthorized('Your account has been blocked. Please contact the administrator.')
      return false
    end
    
    # Check if admin is inactive
    unless @current_admin.is_active
      render_unauthorized('Your account is inactive. Please contact the administrator to activate your account.')
      return false
    end
    
    true
  end
  
  def authorize_admin!
    unless @current_admin
      render_unauthorized('Admin access required')
      return
    end
    
    # Check if admin has permission for specific actions (can be overridden)
    true
  end
  
  def require_super_admin!
    # Check both RBAC and legacy
    has_rbac_role = @current_admin&.has_role?('super_admin')
    has_legacy_role = @current_admin&.super_admin?
    
    unless has_rbac_role || has_legacy_role
      render_unauthorized('Super admin privileges required')
      return
    end
  end
  
  def require_permission!(permission)
    # Use RBAC permission check (with legacy fallback)
    unless @current_admin&.has_permission?(permission)
      render_unauthorized("Permission required: #{permission}")
      return
    end
  end
  
  def require_role!(roles)
    roles = [roles] unless roles.is_a?(Array)
    
    # Check RBAC roles first
    has_rbac_role = roles.any? { |role| @current_admin&.has_role?(role) }
    
    # Fallback to legacy role check
    has_legacy_role = roles.include?(@current_admin&.role&.to_s)
    
    unless has_rbac_role || has_legacy_role
      render_unauthorized('Insufficient privileges for this action')
      return
    end
  end
  
  # Helper to scope resources by permission
  def scope_by_permission(base_scope, resource_type, action = 'view')
    permission_slug = "#{resource_type}:#{action}"
    
    # Super admin can see all
    return base_scope if @current_admin&.super_admin?
    
    # Check if admin has permission
    unless @current_admin&.has_permission?(permission_slug)
      return base_scope.none
    end
    
    base_scope
  end
  
  attr_reader :current_admin
end

