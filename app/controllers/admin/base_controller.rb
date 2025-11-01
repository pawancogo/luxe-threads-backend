module Admin
  class BaseController < ApplicationController
    include ApiResponder
    
    before_action :authenticate_admin!
    before_action :ensure_admin_access!
    
    layout 'admin'
    
    private
    
    def authenticate_admin!
      @current_admin = Admin.find(session[:admin_id]) if session[:admin_id]
      unless @current_admin
        redirect_to '/admin/login', alert: 'Please log in to access admin panel'
        return
      end
    end
    
    def ensure_admin_access!
      # This can be overridden in specific controllers for role-based access
      # For now, any authenticated admin can access
    end
    
    def current_admin
      @current_admin
    end
    
    def super_admin?
      current_admin&.super_admin?
    end
    
    def require_super_admin!
      unless super_admin?
        redirect_to admin_dashboard_path, alert: 'Super admin privileges required'
      end
    end
    
    def admin_dashboard_path
      '/admin'
    end
  end
end


