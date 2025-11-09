# frozen_string_literal: true

module Api::V1::Admin
  class AdminsController < BaseController
    include AdminApiAuthorization
    include StatusManageable
    
    before_action :require_super_admin!
    before_action :set_admin, only: [:show, :update, :destroy, :block, :unblock, :update_status, :resend_invitation]
    
    # GET /api/v1/admin/admins
    def index
      search_params = params.except(:controller, :action).permit(:search, :per_page, :page, :role, :is_active, :is_blocked)
      
      @admins = Admin._search(search_params).order(:role, :first_name)
      
      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      @admins = @admins.page(page).per(per_page)
      
      render_success(format_admins_data(@admins), 'Admins retrieved successfully')
    end
    
    # GET /api/v1/admin/admins/:id
    def show
      render_success(format_admin_detail_data(@admin), 'Admin retrieved successfully')
    end
    
    # PATCH /api/v1/admin/admins/:id
    def update
      admin_params_data = params[:admin] || {}
      
      if @admin.update(admin_params_data.permit(:first_name, :last_name, :email, :phone_number, :role))
        log_admin_activity('update', 'Admin', @admin.id, @admin.previous_changes)
        render_success(format_admin_detail_data(@admin), 'Admin updated successfully')
      else
        render_validation_errors(@admin.errors.full_messages, 'Admin update failed')
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
      service = InvitationService.new(@admin, @current_admin)
      
      if service.send_admin_invitation(role)
        render_created(format_admin_detail_data(@admin), "Invitation sent to #{@admin.email} successfully")
      else
        render_validation_errors(service.errors, 'Failed to send invitation')
      end
    end

    # POST /api/v1/admin/admins/:id/resend_invitation
    def resend_invitation
      service = InvitationService.new(@admin, @current_admin)
      
      if service.resend_invitation
        render_success(format_admin_detail_data(@admin), "Invitation resent to #{@admin.email}")
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
      
      if @admin.destroy
        log_admin_activity('destroy', 'Admin', @admin.id, {})
        render_success({}, 'Admin deleted successfully')
      else
        render_validation_errors(@admin.errors.full_messages, 'Admin deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/admins/:id/block
    def block
      # Prevent super admin from blocking themselves
      if @admin == @current_admin
        render_error('Cannot block your own account', 'You cannot block your own admin account.')
        return
      end
      
      if @admin.block!
        log_admin_activity('block', 'Admin', @admin.id, { is_blocked: [false, true] })
        render_success(format_admin_detail_data(@admin), 'Admin blocked successfully')
      else
        render_validation_errors(@admin.errors.full_messages, 'Failed to block admin')
      end
    end
    
    # PATCH /api/v1/admin/admins/:id/unblock
    def unblock
      if @admin.unblock!
        log_admin_activity('unblock', 'Admin', @admin.id, { is_blocked: [true, false] })
        render_success(format_admin_detail_data(@admin), 'Admin unblocked successfully')
      else
        render_validation_errors(@admin.errors.full_messages, 'Failed to unblock admin')
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
    
    def format_admins_data(admins)
      admins.map do |admin|
        {
          id: admin.id,
          email: admin.email,
          first_name: admin.first_name,
          last_name: admin.last_name,
          full_name: admin.full_name,
          phone_number: admin.phone_number,
          role: admin.role,
          is_active: admin.is_active,
          is_blocked: admin.is_blocked,
          email_verified: admin.email_verified?,
          created_at: admin.created_at,
          last_login_at: admin.last_login_at
        }
      end
    end
    
    def format_admin_detail_data(admin)
      {
        id: admin.id,
        email: admin.email,
        first_name: admin.first_name,
        last_name: admin.last_name,
        full_name: admin.full_name,
        phone_number: admin.phone_number,
        role: admin.role,
        is_active: admin.is_active,
        is_blocked: admin.is_blocked,
        email_verified: admin.email_verified?,
        created_at: admin.created_at,
        updated_at: admin.updated_at,
        last_login_at: admin.last_login_at,
        permissions: {
          can_manage_products: admin.can_manage_products?,
          can_manage_orders: admin.can_manage_orders?,
          can_manage_users: admin.can_manage_users?,
          can_manage_suppliers: admin.can_manage_suppliers?
        }
      }
    end

    # StatusManageable implementation
    def get_status_resource
      @admin
    end

    def activate_resource(resource)
      resource.update(is_active: true)
    end

    def deactivate_resource(resource)
      resource.update(is_active: false)
    end

    def prevent_self_modification?(resource)
      resource == @current_admin
    end

    def format_resource_data(resource)
      format_admin_detail_data(resource)
    end

    def handle_status_success(resource, action)
      log_admin_activity(action, 'Admin', resource.id, { is_active: action == 'activate' ? [false, true] : [true, false] })
      super
    end
  end
end

