class EmailVerificationMailer < ApplicationMailer
  default from: 'noreply@luxethreads.com'

  def send_verification(verification)
    @verification = verification
    @verifiable = verification.verifiable
    @token = verification.verification_token
    @expires_at = verification.created_at + 24.hours
    @verification_url = verification_url(verification)
    
    mail(
      to: @verification.email,
      subject: 'Verify Your Email - LuxeThreads',
      from: "#{Rails.application.config.mailer_from_name} <#{Rails.application.config.mailer_from_email}>"
    )
  end

  private

  def verification_url(verification)
    verifiable = verification.verifiable
    
    # For admins, use backend URL (they use HTML interface)
    if verifiable.is_a?(Admin)
      host = Rails.application.config.host
      port = Rails.application.config.port
      protocol = Rails.env.production? ? 'https' : 'http'
      "#{protocol}://#{host}:#{port}/verify-email?token=#{verification.verification_token}"
    else
      # For users and suppliers, use frontend URL (they use React app)
      frontend_url = Rails.application.config.frontend_url || 'http://localhost:8080'
      "#{frontend_url}/verify-email?token=#{verification.verification_token}"
    end
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
