# frozen_string_literal: true

# Concern for mapping controller actions to permissions
# Follows KISS principle - simple, clear permission mapping
module PermissionMapper
  extend ActiveSupport::Concern

  # Default permission mappings (can be overridden)
  ACTION_PERMISSIONS = {
    'index' => 'view',
    'show' => 'view',
    'create' => 'create',
    'update' => 'update',
    'destroy' => 'delete',
    'edit' => 'update',
    'new' => 'create'
  }.freeze

  private

  # Get permission for current action
  # Usage: permission = permission_for_action
  def permission_for_action(resource_type = nil)
    resource_type ||= self.class.resource_type
    action = ACTION_PERMISSIONS[action_name] || action_name
    
    "#{resource_type}:#{action}"
  end

  # Check if action requires permission
  def requires_permission?
    ACTION_PERMISSIONS.key?(action_name)
  end

  class_methods do
    # Set the resource type for permission checking
    # Usage: resource_type 'products'
    def resource_type(type = nil)
      if type
        @resource_type = type
      else
        @resource_type ||= controller_name.singularize
      end
    end
  end
end

