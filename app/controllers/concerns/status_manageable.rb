# frozen_string_literal: true

# Common concern for managing status (activate/deactivate) across different resources
module StatusManageable
  extend ActiveSupport::Concern

  included do
    # This will be included in controllers that need status management
  end

  # PATCH /resource/:id/status
  # Updates the status based on the 'status_action' parameter
  # Params: status_action: 'activate' or 'deactivate'
  def update_status
    action = params[:status_action] || params[:action]&.to_s
    
    # Skip if action is the controller action name (Rails reserved parameter)
    action = nil if action == 'update_status'
    
    unless %w[activate deactivate].include?(action)
      handle_status_error('Invalid action. Must be "activate" or "deactivate".')
      return
    end
    
    resource = get_status_resource
    return unless resource
    
    # Check if self-modification is allowed
    if prevent_self_modification?(resource)
      handle_status_error('You cannot modify your own account.')
      return
    end
    
    success = case action
    when 'activate'
      activate_resource(resource)
    when 'deactivate'
      deactivate_resource(resource)
    end
    
    if success
      handle_status_success(resource, action)
    else
      handle_status_error("Failed to #{action} resource.")
    end
  end

  private

  # Override in including controller to return the resource instance
  def get_status_resource
    raise NotImplementedError, 'Controllers including StatusManageable must implement get_status_resource'
  end

  # Override in including controller to activate the resource
  def activate_resource(resource)
    raise NotImplementedError, 'Controllers including StatusManageable must implement activate_resource'
  end

  # Override in including controller to deactivate the resource
  def deactivate_resource(resource)
    raise NotImplementedError, 'Controllers including StatusManageable must implement deactivate_resource'
  end

  # Override in including controller if self-modification should be prevented
  def prevent_self_modification?(resource)
    false
  end

  # Override in including controller to handle success response
  def handle_status_success(resource, action)
    resource_name = resource.class.name.underscore.humanize
    if respond_to?(:render_success, true)
      # API controller
      render_success(format_resource_data(resource), "#{resource_name} #{action}d successfully")
    else
      # HTML controller
      redirect_to status_success_path(resource), notice: "#{resource_name} #{action}d successfully."
    end
  end

  # Override in including controller to handle error response
  def handle_status_error(message)
    if respond_to?(:render_error, true)
      # API controller
      render_error('Status update failed', message)
    else
      # HTML controller
      redirect_to status_error_path, alert: message
    end
  end

  # Override in including controller to provide redirect path on success
  def status_success_path(resource)
    raise NotImplementedError, 'HTML controllers including StatusManageable must implement status_success_path'
  end

  # Override in including controller to provide redirect path on error
  def status_error_path
    raise NotImplementedError, 'HTML controllers including StatusManageable must implement status_error_path'
  end

  # Override in including controller to format resource data for API response
  def format_resource_data(resource)
    raise NotImplementedError, 'API controllers including StatusManageable must implement format_resource_data'
  end
end

