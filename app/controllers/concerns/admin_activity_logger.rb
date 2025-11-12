# frozen_string_literal: true

# Concern for logging admin activities consistently
# Extracts admin activity logging logic from controllers
module AdminActivityLogger
  extend ActiveSupport::Concern

  private

  # Log admin activity with automatic resource detection
  # Can be called manually or used as a before_action callback
  def log_admin_activity(action_type = nil, resource_type = nil, resource_id = nil, changes = {})
    return unless @current_admin

    # Auto-detect action type if not provided
    action_type ||= detect_action_type
    
    # Auto-detect resource type if not provided
    resource_type ||= detect_resource_type
    
    # Auto-detect resource ID if not provided
    resource_id ||= detect_resource_id
    
    # Auto-detect changes if not provided and resource is available
    if changes.empty? && @resource && @resource.respond_to?(:changes)
      changes = @resource.changes
    end

    AdminActivity.log_activity(
      @current_admin,
      action_type,
      resource_type,
      resource_id,
      {
        description: build_description(action_type, resource_type),
        changes: changes,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      }
    )
  end

  def detect_action_type
    action = action_name.to_s
    case action
    when /create|admin_create/
      'create'
    when /update|admin_update/
      'update'
    when /destroy|admin_destroy/
      'destroy'
    when /approve/
      'approve'
    when /reject/
      'reject'
    when /block/
      'block'
    when /unblock/
      'unblock'
    when /cancel/
      'cancel'
    when /refund/
      'refund'
    else
      action
    end
  end

  def detect_resource_type
    controller_name.singularize.classify
  end

  def detect_resource_id
    params[:id] || params["#{detect_resource_type.underscore}_id"]
  end

  def build_description(action_type, resource_type)
    "#{action_type.to_s.capitalize} #{resource_type}"
  end

  # Handle service response with automatic admin activity logging
  # Usage: handle_service_with_logging(service, serializer_class, success_message)
  def handle_service_with_logging(service, serializer_class = nil, success_message = 'Operation successful', error_message = 'Operation failed', action_type = nil, resource = nil, changes = {})
    if service.success?
      # Set resource for auto-detection if provided
      @resource = resource || service.result if service.respond_to?(:result)
      
      # Log activity
      log_admin_activity(action_type, nil, nil, changes)
      
      # Render response
      data = if serializer_class && service.respond_to?(:result) && service.result
               serializer_class.new(service.result).as_json
             elsif service.respond_to?(:result)
               service.result
             else
               nil
             end
      
      render_success(data, success_message)
    else
      render_validation_errors(service.errors, error_message)
    end
  end
end

