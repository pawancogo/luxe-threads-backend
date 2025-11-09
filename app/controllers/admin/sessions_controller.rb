class Admin::SessionsController < BaseController
    skip_before_action :authenticate_request, only: [:new, :create, :destroy]
    
    def new
      # Render login view
    end

    def create
      admin = Admin.find_by(email: params[:email])
      
      if admin&.authenticate(params[:password])
        # Check if admin is blocked
        if admin.is_blocked?
          redirect_to '/admin/login?error=Your account has been blocked. Please contact the administrator.'
          return
        end
        
        # Check if admin is inactive (but not blocked)
        unless admin.is_active
          # If email is not verified, redirect to verification flow
          unless admin.email_verified?
            # Send verification OTP if not already sent
            EmailVerificationService.new(admin).send_verification_email unless admin.email_verifications.pending.active.exists?
            redirect_to "/verify-email?type=admin&id=#{admin.id}&email=#{CGI.escape(admin.email)}&reason=inactive"
            return
          else
            # Email verified but account inactive
            redirect_to '/admin/login?error=Your account is inactive. Please contact the administrator to activate your account.'
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
            jwt_token_id: "session_#{session.id}"
          }
        )
        
        # Log admin activity
        AdminActivity.log_activity(
          admin,
          'login',
          nil,
          nil,
          {
            description: 'Admin logged in via SessionsController',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          }
        )
        
        redirect_to '/admin'
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
        redirect_to '/admin/login?error=Invalid credentials or insufficient permissions'
      end
    end

    def destroy
      # Get admin before clearing session
      admin = Admin.find(session[:admin_id]) if session[:admin_id]
      
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
            description: 'Admin logged out via SessionsController',
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          }
        )
      end
      
      session[:admin_id] = nil
      redirect_to '/admin/login'
    end
  end


