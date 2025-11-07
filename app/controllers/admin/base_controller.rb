# Admin controllers base class
# No module namespace - keeps it simple and avoids conflict with Admin model
class Admin::BaseController < BaseController
  before_action :authenticate_admin!
  before_action :ensure_admin_access!
  before_action :set_default_filters

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
  end
  
  def current_admin
    @current_admin
  end
  
  def super_admin?
    current_admin&.super_admin?
  end
  
  def require_super_admin!
    unless super_admin?
      redirect_to admin_root_path, alert: 'Super admin privileges required'
    end
  end
  
  helper_method :current_admin, :super_admin?
  
  # Helper to get controller name without namespace for active link detection
  def controller_name_without_namespace
    self.class.name.demodulize.underscore.gsub('_controller', '')
  end
  helper_method :controller_name_without_namespace
  
  def set_default_filters
    @filters = { search: [nil] }
  end
  
  def enable_date_filter default = nil
    @filters[:date_range] = [default]
    params[:date_range] = default if params[:date_range].blank? && default.present?
  end
  
  def clear_filters
    @filters = {}
  end
  
  def enable_range_filter(range_options = [])
    @filters[:range_term] = range_options if range_options.present?
  end
end


