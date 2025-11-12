class VerificationMailer < ApplicationMailer
  include LoginUrlHelper
  # Generic verification email for any user type
  def verification_email(user, temp_password, user_type = 'user')
    @user = user
    @temp_password = temp_password
    @user_type = user_type.downcase
    @user_type_title = user_type.titleize
    
    subject = case @user_type
    when 'admin'
      'LuxeThreads Admin Account Verification'
    when 'supplier'
      'LuxeThreads Supplier Portal - Account Verification'
    else
      'Welcome to LuxeThreads - Account Verification'
    end
    
    mail(to: @user.email, subject: subject)
  end

  # Generic password reset email for any user type
  def password_reset_email(user, temp_password, token, user_type = 'user')
    @user = user
    @temp_password = temp_password
    @token = token
    @user_type = user_type.downcase
    @user_type_title = user_type.titleize
    
    subject = case @user_type
    when 'admin'
      'LuxeThreads Admin Password Reset Request'
    when 'supplier'
      'LuxeThreads Supplier Password Reset Request'
    else
      'LuxeThreads Password Reset Request'
    end
    
    mail(to: @user.email, subject: subject)
  end

  # Make helper methods available in views
  helper_method :login_url_for_user_type, :supplier_login_url, :user_login_url, :admin_login_url, :admin_login_with_temp_password_url
end


