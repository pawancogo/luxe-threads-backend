# frozen_string_literal: true

# Legacy concern - use AdminAuthorization instead
# Kept for backward compatibility
module AdminApiAuthorization
  extend ActiveSupport::Concern
  include AdminAuthorization
  
  private
  
  # Delegate to AdminAuthorization's authenticate_admin_request
  def authorize_admin!
    authenticate_admin_request unless @current_admin
    super
  end
  
  def require_super_admin!
    authorize_admin! unless @current_admin
    unless @current_admin&.super_admin?
      render_unauthorized('Super admin privileges required')
      return
    end
  end
  
  def require_permission!(permission)
    authorize_admin! unless @current_admin
    unless @current_admin&.has_permission?(permission)
      render_unauthorized("Permission required: #{permission}")
      return
    end
  end
  
  def require_role!(roles)
    authorize_admin! unless @current_admin
    roles = [roles] unless roles.is_a?(Array)
    unless roles.include?(@current_admin&.role)
      render_unauthorized('Insufficient privileges for this action')
      return
    end
  end
  
  # Delegates to AdminActivityLogger concern for consistency
  def log_admin_activity(action_type = nil, resource_type = nil, resource_id = nil, changes = {})
    # Include AdminActivityLogger methods if not already included
    unless self.class.included_modules.include?(AdminActivityLogger)
      self.class.include(AdminActivityLogger)
    end
    super
  end
  
  attr_reader :current_admin
end

