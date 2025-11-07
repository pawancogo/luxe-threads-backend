# frozen_string_literal: true

class Api::V1::PasswordResetController < ApplicationController
  skip_before_action :authenticate_request
  
  # POST /api/v1/password/forgot
  # Sends password reset email with temporary password
  def forgot
    email = params[:email].to_s.strip.downcase
    
    if email.blank?
      render_validation_errors(['Email is required'], 'Email cannot be blank')
      return
    end
    
    user = User.find_by(email: email)
    
    # Always return success to prevent email enumeration
    if user
      begin
        user.send_password_reset_email
        render_success({ message: 'If an account with that email exists, a password reset email has been sent.' }, 'Password reset email sent')
      rescue StandardError => e
        Rails.logger.error "Error sending password reset email: #{e.message}"
        # Still return success to prevent email enumeration
        render_success({ message: 'If an account with that email exists, a password reset email has been sent.' }, 'Password reset email sent')
      end
    else
      # Return success even if user doesn't exist to prevent email enumeration
      render_success({ message: 'If an account with that email exists, a password reset email has been sent.' }, 'Password reset email sent')
    end
  end

  # POST /api/v1/password/reset
  # Resets password using temporary password and new password
  def reset
    email = params[:email].to_s.strip.downcase
    temp_password = params[:temp_password]
    new_password = params[:new_password]
    password_confirmation = params[:password_confirmation] || new_password
    
    # Validate required fields
    if email.blank?
      render_validation_errors(['Email is required'], 'Email cannot be blank')
      return
    end
    
    if temp_password.blank?
      render_validation_errors(['Temporary password is required'], 'Temporary password cannot be blank')
      return
    end
    
    if new_password.blank?
      render_validation_errors(['New password is required'], 'New password cannot be blank')
      return
    end
    
    if new_password != password_confirmation
      render_validation_errors(['Password confirmation does not match'], 'Passwords do not match')
      return
    end
    
    user = User.find_by(email: email)
    
    unless user
      render_unauthorized('Invalid email or temporary password')
      return
    end
    
    # Check if temp password is expired
    if user.temp_password_expired?
      render_error('Temporary password has expired. Please request a new password reset.', 'Password reset expired')
      return
    end
    
    # Reset password
    if user.reset_password_with_temp_password(temp_password, new_password)
      render_success({ message: 'Password has been reset successfully' }, 'Password reset successful')
    else
      render_unauthorized('Invalid email or temporary password')
    end
  end
end

