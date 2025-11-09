# frozen_string_literal: true

# Controller for email verification flow
# Handles OTP generation, verification, and resend functionality
class EmailVerificationController < ActionController::Base
  include VerifiableLookup
  
  protect_from_forgery with: :exception
  
  skip_before_action :verify_authenticity_token, only: [:verify, :resend] if respond_to?(:verify_authenticity_token)
  
  layout :determine_layout
  before_action :load_verifiable_for_layout
  
  # Helper method for admin layout compatibility
  def current_admin
    # Return the admin being verified if it's an admin verification
    # This is used by the admin layout when verifying admin accounts
    if @verifiable&.is_a?(Admin)
      @verifiable
    elsif params[:type] == 'admin' && params[:id].present? && params[:email].present?
      # Fallback: load admin if not already loaded
      Admin.find_by(id: params[:id], email: params[:email])
    else
      nil
    end
  end
  
  def super_admin?
    current_admin&.super_admin? || false
  end
  
  # Navigation helpers for admin layout compatibility
  def navigation_items
    return {} unless current_admin
    NavigationService.visible_items(current_admin)
  end
  
  def can_view_nav_item?(item_key)
    return false unless current_admin
    NavigationService.can_view?(current_admin, item_key)
  end
  
  def controller_name_without_namespace
    controller_name
  end
  
  helper_method :current_admin, :super_admin?, :navigation_items, :can_view_nav_item?, :controller_name_without_namespace
  
  def show
    load_verifiable_for_view(params[:type], params[:id], params[:email])
    
    # Store reason for verification (inactive account, etc.)
    @verification_reason = params[:reason]
    
    # Check if already verified
    if @verifiable.email_verified?
      # If account is inactive, activate it (email verification should activate accounts)
      if @verifiable.respond_to?(:is_active=) && !@verifiable.is_active?
        @verifiable.update!(is_active: true)
        flash.now[:notice] = 'Email already verified! Your account has been activated.'
      elsif @verifiable.is_a?(User) && @verifiable.deleted_at.present?
        @verifiable.update!(deleted_at: nil, is_active: true)
        flash.now[:notice] = 'Email already verified! Your account has been reactivated.'
      else
        flash.now[:notice] = 'Email already verified'
      end
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
      
      # Account activation is now handled automatically in EmailVerification#verify!
      # Reload to get the updated is_active status
      @verifiable.reload
      
      # Check if account is now active (was activated during verification)
      if @verifiable.respond_to?(:is_active?) && @verifiable.is_active?
        flash.now[:notice] = 'Email verified successfully! Your account has been verified and activated.'
        @account_activated = true
      else
        flash.now[:notice] = 'Email verified successfully! Your account is now verified.'
      end
      
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
      flash.now[:notice] = 'Code sent successfully!'
    else
      flash.now[:alert] = 'Failed to send verification code. Please try again.'
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
  
  def load_verifiable_for_layout
    # Load verifiable early for layout determination
    return if params[:type].blank? || params[:id].blank? || params[:email].blank?
    
    @verifiable = begin
      type = params[:type]&.to_s&.downcase
      id = params[:id]
      email = params[:email]
      
      case type
      when 'admin'
        Admin.find_by(id: id, email: email)
      when 'user'
        User.find_by(id: id, email: email)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  def determine_layout
    # Use admin layout if verifying an admin account
    if params[:type] == 'admin' || @verifiable&.is_a?(Admin)
      'admin'
    else
      false # Use standalone layout for users
    end
  end

  def verifiable_params
    params.permit(:type, :id, :otp, :email)
  end
end

