# frozen_string_literal: true

# Controller for email verification flow
# Handles OTP generation, verification, and resend functionality
class EmailVerificationController < ActionController::Base
  include VerifiableLookup
  
  protect_from_forgery with: :exception
  
  skip_before_action :verify_authenticity_token, only: [:verify, :resend] if respond_to?(:verify_authenticity_token)

  def show
    load_verifiable_for_view(params[:type], params[:id], params[:email])
    
    # Check if already verified
    if @verifiable.email_verified?
      flash.now[:notice] = 'Email already verified'
      @verification = nil
      render :show
      return
    end
    
    # Check if there's a pending verification
    @verification = @verifiable.email_verifications.pending.active.first
    unless @verification
      flash.now[:alert] = 'No pending verification found. Please request a new verification code.'
      render :show, status: :unprocessable_entity
    end
  rescue ArgumentError
    flash.now[:alert] = 'Invalid verification link'
    render :show, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = 'Verification record not found'
    render :show, status: :not_found
  end

  def verify
    load_verifiable_for_view(params[:type], params[:id], params[:email])
    
    result = EmailVerificationService.new(@verifiable).verify_email_with_otp(params[:otp])
    
    if result[:success]
      @verification_successful = true
      flash.now[:notice] = 'Email verified successfully! Your account is now verified.'
      @verification = nil
      render :show
    else
      flash.now[:alert] = result[:message]
      @verification = @verifiable.email_verifications.pending.active.first
      render :show, status: :unprocessable_entity
    end
  rescue ArgumentError
    flash.now[:alert] = 'Invalid verification request'
    render :show, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = 'Verification record not found'
    render :show, status: :not_found
  end

  def resend
    email = params[:email] || params.dig(:verifiable, :email)
    load_verifiable_for_view(params[:type], params[:id], email)
    
    service = EmailVerificationService.new(@verifiable)
    
    if service.resend_verification_email
      flash.now[:notice] = 'Verification email sent successfully!'
    else
      flash.now[:alert] = 'Failed to send verification email. Please try again.'
    end
    
    @verification = @verifiable.email_verifications.pending.active.first
    render :show
  rescue ArgumentError
    flash.now[:alert] = 'Invalid request'
    render :show, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = 'Verification record not found'
    render :show, status: :not_found
  end

  private

  def verifiable_params
    params.permit(:type, :id, :otp, :email)
  end
end

