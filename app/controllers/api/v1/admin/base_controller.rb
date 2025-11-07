# frozen_string_literal: true

module Api::V1::Admin
  class BaseController < ApplicationController
    include AdminAuthorization
    
    skip_before_action :authenticate_request
    before_action :log_admin_activity, only: [:create, :update, :destroy, :admin_create, :admin_update, :admin_destroy]
    
    private
    
    def require_role!(roles)
      roles = [roles] unless roles.is_a?(Array)
      unless roles.include?(@current_admin&.role)
        render_unauthorized('Insufficient privileges for this action')
        return
      end
    end
    
    def log_admin_activity
      action_name = action_name.to_s
      resource_type = controller_name.singularize.classify
      
      # Determine action type
      action_type = case action_name
      when /create|admin_create/
        'create'
      when /update|admin_update/
        'update'
      when /destroy|admin_destroy/
        'destroy'
      else
        action_name
      end
      
      # Get resource ID from params
      resource_id = params[:id] || params["#{resource_type.underscore}_id"]
      
      # Get changes if available
      changes = {}
      if @resource && @resource.respond_to?(:changes)
        changes = @resource.changes
      end
      
      AdminActivity.log_activity(
        @current_admin,
        action_type,
        resource_type,
        resource_id,
        {
          description: "#{action_type.capitalize} #{resource_type}",
          changes: changes,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
    end
    
    attr_reader :current_admin
  end
end

