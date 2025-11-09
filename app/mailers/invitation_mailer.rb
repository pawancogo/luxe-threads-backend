# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  default from: 'noreply@luxethreads.com'

  # Admin invitation email
  def admin_invitation(admin, invitation_url, inviter = nil)
    @admin = admin
    @invitation_url = invitation_url
    @inviter = inviter
    @expires_at = admin.invitation_expires_at
    @role = admin.role.humanize
    
    mail(
      to: @admin.email,
      subject: "You've been invited to join LuxeThreads as #{@role}",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end

  # Supplier invitation email
  def supplier_invitation(user, invitation_url, inviter = nil, role = 'supplier')
    @user = user
    @invitation_url = invitation_url
    @inviter = inviter
    @expires_at = user.invitation_expires_at
    @role = role.humanize
    
    mail(
      to: @user.email,
      subject: "You've been invited to join LuxeThreads as #{@role}",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end
end

