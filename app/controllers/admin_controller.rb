class AdminController < BaseController
  before_action :authenticate_admin!, except: [:login]
  before_action :set_current_admin, except: [:login]
  
  # Note: Dashboard is handled by Admin::DashboardController#index
  # This controller only handles login/logout


  def login
    if request.post?
      admin = ::Admin.find_by(email: params[:email])
      
      if admin&.authenticate(params[:password])
        # Check if admin is blocked
        if admin.is_blocked?
          flash.now[:alert] = 'Your account has been blocked. Please contact the administrator.'
          render :login, layout: false
          return
        end
        
        # Check if admin is inactive (but not blocked)
        unless admin.is_active
          # If email is not verified, redirect to verification flow
          unless admin.email_verified?
            # Send verification OTP if not already sent
            EmailVerificationService.new(admin).send_verification_email unless admin.email_verifications.pending.active.exists?
            redirect_to "/verify-email?type=admin&id=#{admin.id}&email=#{CGI.escape(admin.email)}&reason=inactive", 
                        notice: 'Your account is inactive. Please verify your email to activate your account.'
            return
          else
            # Email verified but account inactive - need to activate
            flash.now[:alert] = 'Your account is inactive. Please contact the administrator to activate your account.'
            render :login, layout: false
            return
          end
        end
        
        session[:admin_id] = admin.id
        
        # Update last login
        admin.update_last_login!
        
        # Create login session with device and location info
        LoginSessionService.create_session(
          admin,
          request,
          {
            login_method: 'password',
            platform: 'web',
            jwt_token_id: "session_#{session.id}" # Use session ID as reference
          }
        )
        
        # Log admin activity
        AdminActivity.log_activity(
          admin,
          'login',
          nil,
          nil,
          {
            description: 'Admin logged in via HTML interface',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          }
        )
        
        redirect_to admin_root_path, notice: 'Successfully logged in!'
      else
        # Log failed login attempt
        if admin
          LoginSessionService.create_session(
            admin,
            request,
            {
              login_method: 'password',
              is_successful: false,
              failure_reason: 'Invalid password'
            }
          )
        end
        flash.now[:alert] = 'Invalid email or password'
        render :login, layout: false
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
      LoginSession.for_user(admin)
                  .active
                  .where(logged_out_at: nil)
                  .where("session_token LIKE ?", "session_#{session.id}%")
                  .update_all(logged_out_at: Time.current, is_active: false)
      
      # Log admin activity
      AdminActivity.log_activity(
        admin,
        'logout',
        nil,
        nil,
        {
          description: 'Admin logged out via HTML interface',
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
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
      
      # Invalidate all active login sessions
      LoginSession.for_user(current_admin)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(logged_out_at: Time.current, is_active: false)
      
      # Log the forced logout
      AdminActivity.log_activity(
        current_admin,
        'logout',
        nil,
        nil,
        {
          description: 'Admin automatically logged out due to account being blocked',
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
      
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
