class VerificationController < BaseController
  layout 'admin_auth' # Assuming a layout for authentication pages

  # Generic login with temporary password
  def login_with_temp_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    
    if request.post?
      user = @user_class.find_by(email: params[:email])

      if user && user.authenticate_with_temp_password(params[:temp_password])
        session["#{@user_type}_id".to_sym] = user.id
        redirect_to send("#{@user_type}_reset_password_path"), notice: 'Please set a new password.'
      else
        flash.now[:alert] = 'Invalid email or temporary password.'
        render :login_with_temp_password
      end
    end
  end

  # Generic password reset
  def reset_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    @current_user = get_current_user(@user_type)
    
    unless @current_user && @current_user.password_reset_required?
      redirect_to send("#{@user_type}_dashboard_path"), alert: 'Password reset not required.'
      return
    end

    if request.post?
      if @current_user.reset_password_with_temp_password(params[:temp_password], params[:new_password])
        redirect_to send("#{@user_type}_dashboard_path"), notice: 'Password successfully reset!'
      else
        flash.now[:alert] = 'Failed to reset password. Please check your temporary password and new password requirements.'
        render :reset_password
      end
    end
  end

  # Generic forgot password
  def forgot_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    
    if request.post?
      user = @user_class.find_by(email: params[:email])
      if user
        user.send_password_reset_email
        redirect_to send("#{@user_type}_login_path"), notice: 'If an account with that email exists, a password reset email has been sent.'
      else
        flash.now[:alert] = 'Email not found.'
        render :forgot_password
      end
    end
  end

  private

  def get_user_class(user_type)
    case user_type
    when 'admin'
      Admin
    when 'supplier'
      User
    else
      User
    end
  end

  def get_current_user(user_type)
    case user_type
    when 'admin'
      Admin.find(session[:admin_id]) if session[:admin_id]
    when 'supplier'
      User.find(session[:supplier_id]) if session[:supplier_id] && User.find_by(id: session[:supplier_id])&.role == 'supplier'
    else
      User.find(session[:user_id]) if session[:user_id]
    end
  rescue ActiveRecord::RecordNotFound
    session["#{user_type}_id".to_sym] = nil
    nil
  end
  helper_method :get_current_user
end


