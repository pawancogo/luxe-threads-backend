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
        service = Authentication::PasswordResetService.new(user, user_type: 'user')
        service.call
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
    
    # Reset password using service
    service = Authentication::PasswordResetCompletionService.new(user, temp_password, new_password)
    service.call
    
    if service.success?
      render_success({ message: 'Password has been reset successfully' }, 'Password reset successful')
    else
      render_unauthorized(service.errors.first || 'Invalid email or temporary password')
    end
  end
end

