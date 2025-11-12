class AdminController < BaseController
  before_action :authenticate_admin!, except: [:login]
  before_action :set_current_admin, except: [:login]
  
  # Note: Dashboard is handled by Admin::DashboardController#index
  # This controller only handles login/logout


  def login
    if request.post?
      service = Admins::HtmlAuthenticationService.new(
        params[:email],
        params[:password],
        request,
        session.id
      )
      service.call
      
      if service.success?
        session[:admin_id] = service.admin.id
        redirect_to admin_root_path, notice: 'Successfully logged in!'
      else
        # Check if there's a special result (for inactive accounts)
        if service.result.is_a?(Hash) && service.result[:error_code]
          redirect_to service.result[:verification_url], notice: service.errors.first
        else
          flash.now[:alert] = service.errors.first || 'Invalid email or password'
          render :login, layout: false
        end
      end
    else
      render :login, layout: false
    end
  end

  def logout
    # Get admin before clearing session
    admin = current_admin
    
    # Mark login session as logged out
    if admin
      service = Admins::LogoutService.new(admin, request, session_token: "session_#{session.id}")
      service.call
    end
    
    session[:admin_id] = nil
    redirect_to admin_login_path, notice: 'Successfully logged out!'
  end

  def route_not_found
    render html: <<~HTML.html_safe, status: :not_found, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>404 - Page Not Found</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
          body { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f8f9fa; }
        </style>
      </head>
      <body>
        <div class="text-center">
          <h1 class="display-1">404</h1>
          <h2>Page Not Found</h2>
          <p class="text-muted">The page you're looking for doesn't exist.</p>
          <a href="/admin" class="btn btn-primary">Go to Admin Dashboard</a>
        </div>
      </body>
      </html>
    HTML
  end

  private

  def authenticate_admin!
    unless current_admin
      redirect_to admin_login_path, alert: 'Please log in to access admin panel'
      return
    end
    
    # Check if admin is blocked - if so, log them out immediately
    if current_admin.is_blocked?
      # Clear Rails session completely
      reset_session
      
      # Invalidate all active login sessions using service
      service = Admins::LogoutService.new(current_admin, request)
      service.call
      
      redirect_to admin_login_path, alert: 'Your account has been blocked. Please contact the administrator.'
      return
    end
    
    # Check if admin is inactive - show verification modal to reactivate account
    unless current_admin.is_active
      # When account is inactive, admin must verify email via OTP to reactivate
      # Send verification OTP if not already sent
      unless current_admin.email_verifications.pending.active.exists?
        EmailVerificationService.new(current_admin).send_verification_email
      end
      
      # Set session flag to trigger modal
      session[:show_inactive_modal] = true
      session[:verification_url] = "/verify-email?type=admin&id=#{current_admin.id}&email=#{CGI.escape(current_admin.email)}&reason=inactive"
      
      # Don't redirect immediately - let JavaScript modal handle it
      # This allows the modal to show on the current page
    end
  end

  def current_admin
    @current_admin ||= ::Admin.find(session[:admin_id]) if session[:admin_id]
  rescue ActiveRecord::RecordNotFound
    session[:admin_id] = nil
    nil
  end

  def set_current_admin
    @current_admin = current_admin
  end

  helper_method :current_admin
end
