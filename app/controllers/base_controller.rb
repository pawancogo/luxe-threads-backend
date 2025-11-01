class BaseController < ActionController::Base
  # This controller is for HTML responses (admin interface)
  # It doesn't include API authentication
  include Pundit::Authorization
  
  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  
  # Override Pundit's user method to use current_admin
  def pundit_user
    current_admin
  end
end
