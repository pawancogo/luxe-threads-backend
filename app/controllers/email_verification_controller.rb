class EmailVerificationController < ApplicationController
  include ApiResponder
  skip_before_action :authenticate_request, only: [:show, :verify, :resend]

  def show
    # This will be used to show the verification form
    # The verifiable object will be passed via params
    @verifiable_type = params[:type]
    @verifiable_id = params[:id]
    @email = params[:email]
    
    # Find the verifiable object
    case @verifiable_type
    when 'admin'
      @verifiable = Admin.find(@verifiable_id)
    when 'user'
      @verifiable = User.find(@verifiable_id)
    when 'supplier'
      @verifiable = Supplier.find(@verifiable_id)
    else
      redirect_to root_path, alert: 'Invalid verification link'
      return
    end
    
    # Check if already verified
    if @verifiable.email_verified?
      redirect_to root_path, notice: 'Email already verified'
      return
    end
    
    # Check if there's a pending verification
    @verification = @verifiable.email_verifications.pending.active.first
    unless @verification
      redirect_to root_path, alert: 'No pending verification found'
      return
    end
  end

  def verify
    @verifiable_type = params[:type]
    @verifiable_id = params[:id]
    @otp = params[:otp]
    
    # Find the verifiable object
    case @verifiable_type
    when 'admin'
      @verifiable = Admin.find(@verifiable_id)
    when 'user'
      @verifiable = User.find(@verifiable_id)
    when 'supplier'
      @verifiable = Supplier.find(@verifiable_id)
    else
      render_bad_request('Invalid verification request')
      return
    end
    
    # Verify the OTP
    result = EmailVerificationService.new(@verifiable).verify_email_with_otp(@otp)
    
    if result[:success]
      # Redirect based on user type
      case @verifiable_type
      when 'admin'
        redirect_to '/admin/login', notice: 'Email verified successfully! You can now login.'
      when 'user'
        redirect_to '/api/v1/login', notice: 'Email verified successfully! You can now login.'
      when 'supplier'
        redirect_to '/supplier/login', notice: 'Email verified successfully! You can now login.'
      end
    else
      flash.now[:alert] = result[:message]
      render :show, status: :unprocessable_entity
    end
  end

  def resend
    @verifiable_type = params[:type]
    @verifiable_id = params[:id]
    
    # Find the verifiable object
    case @verifiable_type
    when 'admin'
      @verifiable = Admin.find(@verifiable_id)
    when 'user'
      @verifiable = User.find(@verifiable_id)
    when 'supplier'
      @verifiable = Supplier.find(@verifiable_id)
    else
      render_bad_request('Invalid request')
      return
    end
    
    # Resend verification email
    if EmailVerificationService.new(@verifiable).resend_verification_email
      flash.now[:notice] = 'Verification email sent successfully!'
    else
      flash.now[:alert] = 'Failed to send verification email'
    end
    
    render :show
  end

  private

  def verifiable_params
    params.permit(:type, :id, :otp, :email)
  end
end
