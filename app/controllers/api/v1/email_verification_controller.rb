# frozen_string_literal: true

class Api::V1::EmailVerificationController < ApplicationController
  skip_before_action :authenticate_request, only: [:verify, :resend]
  
  # GET /api/v1/email/verify
  # Verify email with token (public endpoint)
  def verify
    token = params[:token]
    
    unless token.present?
      render_validation_errors(['Token is required'], 'Verification token is missing')
      return
    end
    
    # Find verification by token
    verification = EmailVerification.find_by(verification_token: token)
    
    unless verification
      render_not_found('Invalid verification token')
      return
    end
    
    if verification.expired?
      render_error('Verification token has expired', 'Please request a new verification email', :unprocessable_entity)
      return
    end
    
    if verification.verified?
      render_success({ email: verification.email, verified: true }, 'Email is already verified')
      return
    end
    
    # Verify using the service
    result = verification.verifiable.verify_email_with_token(token)
    
    if result[:success]
      render_success({ email: verification.email, verified: true }, result[:message] || 'Email verified successfully')
    else
      render_error('Email verification failed', result[:message], :unprocessable_entity)
    end
  end

  # POST /api/v1/email/resend
  # Resend verification email (public endpoint, requires email)
  def resend
    email = params[:email]
    
    unless email.present?
      render_validation_errors(['Email is required'], 'Email address is required')
      return
    end
    
    user = User.find_by(email: email)
    
    unless user
      # Don't reveal if email exists or not for security
      render_success({ message: 'If the email exists, a verification email has been sent' }, 'Verification email sent')
      return
    end
    
    if user.email_verified?
      render_success({ email: user.email, verified: true }, 'Email is already verified')
      return
    end
    
    begin
      user.send_verification_email
      render_success({ message: 'Verification email sent successfully' }, 'Verification email sent')
    rescue StandardError => e
      Rails.logger.error "Error sending verification email: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_server_error('Failed to send verification email', e)
    end
  end

  # POST /api/v1/email/resend_authenticated
  # Resend verification email for authenticated user
  def resend_authenticated
    if current_user.email_verified?
      render_success({ email: current_user.email, verified: true }, 'Email is already verified')
      return
    end
    
    begin
      current_user.send_verification_email
      render_success({ message: 'Verification email sent successfully' }, 'Verification email sent')
    rescue StandardError => e
      Rails.logger.error "Error sending verification email: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_server_error('Failed to send verification email', e)
    end
  end

  # GET /api/v1/email/status
  # Check verification status for authenticated user
  def status
    status = current_user.verification_status
    verification = current_user.email_verifications.pending.active.first
    
    render_success({
      email: current_user.email,
      verified: current_user.email_verified?,
      status: status,
      verification_sent_at: verification&.created_at&.iso8601
    }, 'Verification status retrieved successfully')
  end
end

