class VerificationController < BaseController
  layout 'admin_auth' # Assuming a layout for authentication pages

  # Generic login with temporary password
  def login_with_temp_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    
    if request.post?
      email = params[:email]&.strip
      temp_password = params[:temp_password]
      
      unless email.present? && temp_password.present?
        flash.now[:alert] = 'Email and temporary password are required.'
        render :login_with_temp_password
        return
      end
      
      user = @user_class.find_by(email: email)
      
      unless user
        flash.now[:alert] = 'Invalid email or temporary password.'
        render :login_with_temp_password
        return
      end
      
      # Check if temp password is expired
      if user.temp_password_expired?
        flash.now[:alert] = 'Temporary password has expired. Please request a new password reset.'
        render :login_with_temp_password
        return
      end
      
      if user.authenticate_with_temp_password(temp_password)
        # Set session and redirect to password reset page
        session["#{@user_type}_id".to_sym] = user.id
        redirect_to admin_auth_reset_password_path(user_type: @user_type), notice: 'Please set a new password.'
      else
        flash.now[:alert] = 'Invalid email or temporary password.'
        render :login_with_temp_password
      end
    end
  end

  # Generic password reset - token-based
  def reset_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    @token = params[:token]
    
    # Verify token and find user
    if @token.present?
      @current_user = @user_class.find_by(password_reset_token: @token)
      
      unless @current_user && TempPasswordService.verify_reset_token(@current_user, @token)
        flash[:alert] = 'Invalid or expired password reset link. Please request a new password reset.'
        redirect_to admin_auth_forgot_password_path(user_type: @user_type)
        return
      end
      
      # Check if password reset is required
      unless @current_user.password_reset_required?
        redirect_to admin_login_path, alert: 'Password reset not required. Please log in normally.'
        return
      end
    else
      flash[:alert] = 'Invalid password reset link. Please request a new password reset.'
      redirect_to admin_auth_forgot_password_path(user_type: @user_type)
      return
    end

    if request.post?
      new_password = params[:new_password]
      new_password_confirmation = params[:new_password_confirmation]
      
      # Validate password confirmation
      if new_password != new_password_confirmation
        flash.now[:alert] = 'New password and confirmation do not match.'
        render :reset_password
        return
      end
      
      # Validate new password
      unless PasswordValidationService.valid?(new_password)
        flash.now[:alert] = PasswordValidationService.errors(new_password).join(', ')
        render :reset_password
        return
      end
      
      # Update password directly (no need for temp password since we verified token)
      @current_user.password = new_password
      @current_user.password_confirmation = new_password
      
      if @current_user.save
        # Clear temp password and token
        TempPasswordService.clear_temp_password(@current_user)
        redirect_to admin_login_path, notice: 'Password successfully reset! Please log in with your new password.'
      else
        error_messages = @current_user.errors.full_messages
        flash.now[:alert] = error_messages.any? ? error_messages.join(', ') : 'Failed to reset password. Please check password requirements.'
        render :reset_password
      end
    end
  end

  # Generic forgot password
  def forgot_password
    @user_type = params[:user_type] || 'user'
    @user_class = get_user_class(@user_type)
    
    if request.post?
      # Try to find user in the specified class first
      user = @user_class.find_by(email: params[:email])
      
      # If not found and user_type is 'user', also check Admin model
      # This handles cases where admin forgot password but user_type wasn't set
      if user.nil? && @user_type == 'user'
        admin = Admin.find_by(email: params[:email])
        if admin
          user = admin
          @user_type = 'admin'
          @user_class = Admin
        end
      end
      
      if user
        service = Authentication::PasswordResetService.new(user, user_type: @user_type)
        service.call
        redirect_to admin_login_path, notice: 'If an account with that email exists, a password reset email has been sent.'
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


