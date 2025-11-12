# frozen_string_literal: true

module Api::V1::Admin
  class AdminsController < BaseController
    include AdminApiAuthorization
    include StatusManageable
    
    before_action :require_super_admin!
    before_action :set_admin, only: [:show, :update, :destroy, :block, :unblock, :update_status, :resend_invitation]
    
    # GET /api/v1/admin/admins
    def index
      service = Admins::AdminListingService.new(Admin.all, params)
      service.call
      
      if service.success?
        render_success(
          AdminAdminSerializer.collection(service.admins),
          'Admins retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve admins')
      end
    end
    
    # GET /api/v1/admin/admins/:id
    def show
      render_success(
        AdminAdminSerializer.new(@admin).as_json,
        'Admin retrieved successfully'
      )
    end
    
    # PATCH /api/v1/admin/admins/:id
    def update
      admin_params_data = params[:admin] || {}
      
      service = Admins::UpdateService.new(@admin, admin_params_data.permit(:first_name, :last_name, :email, :phone_number, :role))
      service.call
      
      if service.success?
        log_admin_activity('update', 'Admin', @admin.id, @admin.previous_changes)
        render_success(
          AdminAdminSerializer.new(@admin.reload).as_json,
          'Admin updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Admin update failed')
      end
    end
    
    # POST /api/v1/admin/admins/invite
    def invite
      admin_params_data = params[:admin] || {}
      email = admin_params_data[:email]
      role = admin_params_data[:role]
      
      unless email.present? && role.present?
        render_validation_errors(['Email and role are required'], 'Invitation failed')
        return
      end
      
      @admin = Admin.find_or_initialize_by(email: email)
      service = Invitations::Service.new(@admin, @current_admin)
      
      if service.send_admin_invitation(role)
        render_created(
          AdminAdminSerializer.new(@admin).as_json,
          "Invitation sent to #{@admin.email} successfully"
        )
      else
        render_validation_errors(service.errors, 'Failed to send invitation')
      end
    end

    # POST /api/v1/admin/admins/:id/resend_invitation
    def resend_invitation
      service = Invitations::Service.new(@admin, @current_admin)
      
      if service.resend_invitation
        render_success(
          AdminAdminSerializer.new(@admin).as_json,
          "Invitation resent to #{@admin.email}"
        )
      else
        render_validation_errors(service.errors, 'Failed to resend invitation')
      end
    end

    # DELETE /api/v1/admin/admins/:id
    def destroy
      # Prevent super admin from deleting themselves
      if @admin == @current_admin
        render_error('Cannot delete your own account', 'You cannot delete your own admin account.')
        return
      end
      
      service = Admins::DeletionService.new(@admin)
      service.call
      
      if service.success?
        log_admin_activity('destroy', 'Admin', @admin.id, {})
        render_success({}, 'Admin deleted successfully')
      else
        render_validation_errors(service.errors, 'Admin deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/admins/:id/block
    def block
      # Prevent super admin from blocking themselves
      if @admin == @current_admin
        render_error('Cannot block your own account', 'You cannot block your own admin account.')
        return
      end
      
      service = Admins::BlockService.new(@admin)
      service.call
      
      if service.success?
        log_admin_activity('block', 'Admin', @admin.id, { is_blocked: [false, true] })
        render_success(
          AdminAdminSerializer.new(@admin.reload).as_json,
          'Admin blocked successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to block admin')
      end
    end
    
    # PATCH /api/v1/admin/admins/:id/unblock
    def unblock
      service = Admins::UnblockService.new(@admin)
      service.call
      
      if service.success?
        log_admin_activity('unblock', 'Admin', @admin.id, { is_blocked: [true, false] })
        render_success(
          AdminAdminSerializer.new(@admin.reload).as_json,
          'Admin unblocked successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to unblock admin')
      end
    end
    
    # Uses StatusManageable concern
    def update_status
      super
    end
    
    private
    
    def set_admin
      @admin = Admin.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('Admin not found')
    end
    
    # StatusManageable implementation
    def get_status_resource
      @admin
    end

    def activate_resource(resource)
      service = Admins::ActivationService.new(resource)
      service.call
      service.success?
    end

    def deactivate_resource(resource)
      service = Admins::DeactivationService.new(resource)
      service.call
      service.success?
    end

    def prevent_self_modification?(resource)
      resource == @current_admin
    end

    def format_resource_data(resource)
      AdminAdminSerializer.new(resource).as_json
    end

    def handle_status_success(resource, action)
      log_admin_activity(action, 'Admin', resource.id, { is_active: action == 'activate' ? [false, true] : [true, false] })
      super
    end
  end
end

