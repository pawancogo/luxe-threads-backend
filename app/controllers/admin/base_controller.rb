# Admin controllers base class
# No module namespace - keeps it simple and avoids conflict with Admin model
class Admin::BaseController < BaseController
  before_action :authenticate_admin!
  before_action :ensure_admin_access!
  before_action :set_default_filters
  before_action :set_paper_trail_whodunnit
  before_action :set_paper_trail_metadata

  layout 'admin'
  
  private
  
  def authenticate_admin!
    @current_admin = Admin.find(session[:admin_id]) if session[:admin_id]
    unless @current_admin
      redirect_to '/admin/login', alert: 'Please log in to access admin panel'
      return
    end
    
    # Check if admin is blocked - if so, log them out immediately
    if @current_admin.is_blocked?
      # Clear Rails session completely
      reset_session
      
      # Invalidate all active login sessions
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
      
      redirect_to '/admin/login', alert: 'Your account has been blocked. Please contact the administrator.'
      return
    end
    
    # Check if admin is inactive - show verification modal to reactivate account
    unless @current_admin.is_active
      # When account is inactive, admin must verify email via OTP to reactivate
      # Send verification OTP if not already sent
      unless @current_admin.email_verifications.pending.active.exists?
        EmailVerificationService.new(@current_admin).send_verification_email
      end
      
      # Set session flag to trigger modal
      session[:show_inactive_modal] = true
      session[:verification_url] = "/verify-email?type=admin&id=#{@current_admin.id}&email=#{CGI.escape(@current_admin.email)}&reason=inactive"
      
      # Don't redirect immediately - let JavaScript modal handle it
      # This allows the modal to show on the current page
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
  
  # Dynamic navigation helpers using NavigationService
  def navigation_items
    NavigationService.visible_items(current_admin)
  end
  
  def can_view_nav_item?(item_key)
    NavigationService.can_view?(current_admin, item_key)
  end
  
  # Legacy permission helpers (for backward compatibility)
  # These now delegate to NavigationService for dynamic checking
  def can_view_users?
    NavigationService.can_view?(current_admin, :users)
  end
  
  def can_view_suppliers?
    NavigationService.can_view?(current_admin, :suppliers)
  end
  
  def can_view_products?
    NavigationService.can_view?(current_admin, :products)
  end
  
  def can_view_categories?
    NavigationService.can_view?(current_admin, :categories)
  end
  
  def can_view_orders?
    NavigationService.can_view?(current_admin, :orders)
  end
  
  def can_view_promotions?
    NavigationService.can_view?(current_admin, :promotions)
  end
  
  def can_view_coupons?
    NavigationService.can_view?(current_admin, :coupons)
  end
  
  def can_view_reports?
    NavigationService.can_view?(current_admin, :reports)
  end
  
  def can_view_audit_logs?
    NavigationService.can_view?(current_admin, :audit_logs)
  end
  
  def can_view_settings?
    NavigationService.can_view?(current_admin, :settings)
  end
  
  def can_view_email_templates?
    NavigationService.can_view?(current_admin, :email_templates)
  end
  
  helper_method :navigation_items, :can_view_nav_item?,
                :can_view_users?, :can_view_suppliers?, :can_view_products?, 
                :can_view_categories?, :can_view_orders?, :can_view_promotions?, 
                :can_view_coupons?, :can_view_reports?, :can_view_audit_logs?, 
                :can_view_settings?, :can_view_email_templates?
  
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
  
  def enable_range_filter(range_field = nil)
    @filters[:range_field] = range_field if range_field.present?
  end
  
  # PaperTrail integration
  def set_paper_trail_whodunnit
    if current_admin
      PaperTrail.request.whodunnit = "Admin:#{current_admin.id}"
    end
  end
  
  def set_paper_trail_metadata
    return unless request
    
    # Determine source of change
    source = if request.path.start_with?('/admin')
      'Admin Panel'
    elsif request.path.start_with?('/api')
      'API'
    else
      'Web'
    end
    
    # Store metadata - only store fields that exist as columns in versions table
    # Note: versions table has ip_address and user_agent columns, but not request_id or meta
    # So we only store what can be saved as direct attributes
    PaperTrail.request.controller_info = {
      ip_address: request.remote_ip,
      user_agent: request.user_agent
      # request_id, controller, action, source, path, method are not columns
      # and meta column doesn't exist, so we can't store them
    }.compact
  end
end


