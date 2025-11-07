# RailsAdmin Authentication Configuration
# This file ensures RailsAdmin can access the current_admin method
# and authenticate users based on session

Rails.application.config.to_prepare do
  # Add current_admin method to RailsAdmin::ApplicationController
  RailsAdmin::ApplicationController.class_eval do
    def current_admin
      @current_admin ||= begin
        if session[:admin_id]
          Admin.find(session[:admin_id])
        else
          nil
        end
      rescue ActiveRecord::RecordNotFound
        session[:admin_id] = nil
        nil
      end
    end

    helper_method :current_admin
  end
end

