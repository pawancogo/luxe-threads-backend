class Admin::SessionsController < BaseController
    skip_before_action :authenticate_request, only: [:new, :create, :destroy]
    
    def new
      # Render login view
    end

    def create
      service = Admins::HtmlAuthenticationService.new(
        params[:email],
        params[:password],
        request,
        session.id
      )
      service.call
      
      if service.success?
        session[:admin_id] = service.admin.id
        redirect_to '/admin'
      else
        # Check if there's a special result (for inactive accounts)
        if service.result.is_a?(Hash) && service.result[:error_code]
          redirect_to service.result[:verification_url], notice: service.errors.first
        else
          redirect_to '/admin/login?error=' + CGI.escape(service.errors.first || 'Invalid credentials or insufficient permissions')
        end
      end
    end

    def destroy
      # Get admin before clearing session
      admin = Admin.find(session[:admin_id]) if session[:admin_id]
      
      # Mark login session as logged out
      if admin
        service = Admins::LogoutService.new(admin, request, session_token: "session_#{session.id}")
        service.call
      end
      
      session[:admin_id] = nil
      redirect_to '/admin/login'
    end
  end


