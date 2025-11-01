class EmailVerificationMailer < ApplicationMailer
  default from: 'noreply@luxethreads.com'

  def send_otp(verification)
    @verification = verification
    @verifiable = verification.verifiable
    @otp = verification.otp
    @expires_at = verification.created_at + Rails.application.config.otp_expiry_minutes.minutes
    @verification_url = verification_url(verification)
    
    mail(
      to: @verification.email,
      subject: 'Verify Your Email - LuxeThreads',
      from: "#{Rails.application.config.mailer_from_name} <#{Rails.application.config.mailer_from_email}>"
    )
  end

  private

  def verification_url(verification)
    host = Rails.application.config.host
    port = Rails.application.config.port
    protocol = Rails.env.production? ? 'https' : 'http'
    
    "#{protocol}://#{host}:#{port}/verify-email?type=#{verification.verifiable_type.downcase}&id=#{verification.verifiable_id}&email=#{verification.email}"
  end

  def welcome_after_verification(verifiable)
    @verifiable = verifiable
    
    case verifiable.class.name
    when 'Admin'
      @login_url = '/admin/login'
      @user_type = 'Admin'
    when 'User'
      @login_url = '/api/v1/login'
      @user_type = 'Customer'
    when 'Supplier'
      @login_url = '/supplier/login'
      @user_type = 'Supplier'
    end
    
    mail(
      to: verifiable.email,
      subject: 'Welcome to LuxeThreads!'
    )
  end
end
