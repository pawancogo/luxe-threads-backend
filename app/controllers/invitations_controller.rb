# frozen_string_literal: true

# Controller for accepting invitations (both admin and supplier)
class InvitationsController < ApplicationController
  skip_before_action :authenticate_request, only: [:show, :accept]
  
  # GET /admin/invitations/accept?token=xxx
  # GET /supplier/invitations/accept?token=xxx
  def show
    @token = params[:token]
    @invitee = find_invitee_by_token(@token)
    
    unless @invitee
      render_invalid_token
      return
    end
    
    service = InvitationService.new(@invitee)
    
    if service.invitation_expired?
      render_expired_invitation
      return
    end
    
    if service.invitation_already_accepted?
      render_already_accepted
      return
    end
    
    # Render invitation acceptance form
    @invitation_type = @invitee.is_a?(Admin) ? 'admin' : 'supplier'
    
    # Check if this is a child supplier (invited to join existing account)
    @is_child_supplier = false
    if @invitee.is_a?(User) && @invitee.role == 'supplier'
      @is_child_supplier = @invitee.supplier_account_users.exists?(status: 'pending_invitation')
      if @is_child_supplier
        @supplier_account_user = @invitee.supplier_account_users.find_by(status: 'pending_invitation')
        @supplier_profile = @supplier_account_user&.supplier_profile
      end
    end
    
    render :accept, layout: false
  end

  # POST /admin/invitations/accept
  # POST /supplier/invitations/accept
  def accept
    @token = params[:token]
    @invitee = find_invitee_by_token(@token)
    
    unless @invitee
      render_invalid_token
      return
    end
    
    service = InvitationService.new(@invitee)
    
    unless service.valid_invitation_token?(@token)
      render_invalid_token
      return
    end
    
    if service.invitation_expired?
      render_expired_invitation
      return
    end
    
    if service.invitation_already_accepted?
      render_already_accepted
      return
    end
    
    # Accept invitation (includes token in params for validation)
    invitation_params_with_token = invitation_params.merge(token: @token)
    
    if service.accept_invitation(invitation_params_with_token)
      @invitation_type = @invitee.is_a?(Admin) ? 'admin' : 'supplier'
      render :success, layout: false
    else
      @errors = service.errors
      @invitation_type = @invitee.is_a?(Admin) ? 'admin' : 'supplier'
      # Preserve form values for re-rendering
      @form_params = params[:invitation] || {}
      render :accept, status: :unprocessable_entity, layout: false
    end
  end

  private

  def find_invitee_by_token(token)
    return nil if token.blank?
    
    # Try Admin first
    admin = Admin.find_by(invitation_token: token)
    return admin if admin.present?
    
    # Try User (supplier)
    User.find_by(invitation_token: token)
  end

  def invitation_params
    params.require(:invitation).permit(
      :first_name,
      :last_name,
      :phone_number,
      :password,
      :password_confirmation,
      supplier_profile_attributes: [
        :company_name,
        :gst_number,
        :description,
        :website_url
      ]
    )
  end

  def render_invalid_token
    render html: <<~HTML.html_safe, status: :not_found, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>Invalid Invitation</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body class="bg-light">
        <div class="container mt-5">
          <div class="row justify-content-center">
            <div class="col-md-6">
              <div class="card">
                <div class="card-body text-center">
                  <h2 class="text-danger">Invalid Invitation</h2>
                  <p>The invitation link is invalid or has been used.</p>
                  <a href="/" class="btn btn-primary">Go to Home</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  def render_expired_invitation
    render html: <<~HTML.html_safe, status: :gone, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>Invitation Expired</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body class="bg-light">
        <div class="container mt-5">
          <div class="row justify-content-center">
            <div class="col-md-6">
              <div class="card">
                <div class="card-body text-center">
                  <h2 class="text-warning">Invitation Expired</h2>
                  <p>This invitation has expired. Please contact the administrator for a new invitation.</p>
                  <a href="/" class="btn btn-primary">Go to Home</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  def render_already_accepted
    render html: <<~HTML.html_safe, status: :ok, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>Invitation Already Accepted</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body class="bg-light">
        <div class="container mt-5">
          <div class="row justify-content-center">
            <div class="col-md-6">
              <div class="card">
                <div class="card-body text-center">
                  <h2 class="text-info">Invitation Already Accepted</h2>
                  <p>This invitation has already been accepted.</p>
                  <a href="/admin/login" class="btn btn-primary">Go to Login</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end
end

