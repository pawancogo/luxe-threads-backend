class BaseController < ActionController::Base
  # This controller is for HTML responses (admin interface)
  # It doesn't include API authentication
  include Pundit::Authorization
  
  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || admin_root_path)
  end
  
  def route_not_found
    respond_to do |format|
      format.html { 
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
      }
      format.json { render json: { error: 'Route not found', message: 'The requested route does not exist' }, status: :not_found }
    end
  end
  
  # Override Pundit's user method to use current_admin
  def pundit_user
    current_admin
  end
end
