# frozen_string_literal: true

module Api::V1::Admin
  class BaseController < ApplicationController
    include AdminAuthorization
    include AdminActivityLogger
    
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
    
    attr_reader :current_admin
  end
end

