# frozen_string_literal: true

module Api::V1::Admin
  class SuppliersController < BaseController
    include AdminApiAuthorization
    
    before_action :require_supplier_admin_role!, only: [:index, :show, :update, :destroy, :activate, :deactivate, :suspend, :invite, :resend_invitation]
    before_action :set_supplier, only: [:show, :update, :destroy, :activate, :deactivate, :suspend, :stats, :resend_invitation]
    
    # GET /api/v1/admin/suppliers
    def index
      base_scope = User.suppliers_only.with_supplier_profile
      
      service = Admins::SupplierListingService.new(base_scope, params)
      service.call
      
      if service.success?
        render_success(
          AdminSupplierSerializer.collection(service.suppliers),
          'Suppliers retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve suppliers')
      end
    end
    
    # GET /api/v1/admin/suppliers/:id
    def show
      render_success(
        AdminSupplierSerializer.new(@supplier).as_json,
        'Supplier retrieved successfully'
      )
    end
    
    # PATCH /api/v1/admin/suppliers/:id
    def update
      supplier_params_data = params[:supplier] || {}
      
      # Normalize params for service (service expects supplier_profile_attributes)
      normalized_params = supplier_params_data.permit(:first_name, :last_name, :phone_number, :email)
      if supplier_params_data[:supplier_profile].present?
        normalized_params[:supplier_profile_attributes] = supplier_params_data[:supplier_profile].permit(:company_name, :gst_number, :description, :website_url)
      end
      
      service = Suppliers::UpdateService.new(@supplier, normalized_params)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Supplier', @supplier.id, @supplier.previous_changes)
        render_success(
          AdminSupplierSerializer.new(@supplier.reload).as_json,
          'Supplier updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Supplier update failed')
      end
    end
    
    # DELETE /api/v1/admin/suppliers/:id
    def destroy
      supplier_id = @supplier.id
      if @supplier.destroy
        log_admin_activity('destroy', 'Supplier', supplier_id)
        render_success({ id: supplier_id }, 'Supplier deleted successfully')
      else
        render_validation_errors(@supplier.errors.full_messages, 'Supplier deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/suppliers/:id/activate
    def activate
      service = Suppliers::StatusUpdateService.new(@supplier, 'active', admin: @current_admin)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Supplier', @supplier.id, { status: 'active' })
        render_success(
          AdminSupplierSerializer.new(@supplier.reload).as_json,
          'Supplier activated successfully'
        )
      else
        render_validation_errors(service.errors, 'Supplier activation failed')
      end
    end
    
    # PATCH /api/v1/admin/suppliers/:id/deactivate
    def deactivate
      service = Suppliers::StatusUpdateService.new(@supplier, 'inactive', admin: @current_admin)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Supplier', @supplier.id, { status: 'inactive' })
        render_success(
          AdminSupplierSerializer.new(@supplier.reload).as_json,
          'Supplier deactivated successfully'
        )
      else
        render_validation_errors(service.errors, 'Supplier deactivation failed')
      end
    end
    
    # PATCH /api/v1/admin/suppliers/:id/suspend
    def suspend
      suspension_reason = params[:suspension_reason] || 'Supplier account suspended by admin'
      service = Suppliers::StatusUpdateService.new(@supplier, 'suspended', suspension_reason: suspension_reason, admin: @current_admin)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Supplier', @supplier.id, { status: 'suspended', suspension_reason: suspension_reason })
        render_success(
          AdminSupplierSerializer.new(@supplier.reload).as_json,
          'Supplier suspended successfully'
        )
      else
        render_validation_errors(service.errors, 'Supplier suspension failed')
      end
    end
    
    # POST /api/v1/admin/suppliers/invite
    def invite
      supplier_params_data = params[:supplier] || {}
      email = supplier_params_data[:email]
      invitation_role = supplier_params_data[:invitation_role] || 'supplier'
      supplier_profile_id = supplier_params_data[:supplier_profile_id]
      account_role = supplier_params_data[:account_role] || 'staff'
      
      unless email.present?
        render_validation_errors(['Email is required'], 'Invitation failed')
        return
      end
      
      @supplier = User.find_or_initialize_by(email: email)
      @supplier.role = 'supplier' if @supplier.new_record?
      
      # Build options for child supplier invitation
      options = {}
      if supplier_profile_id.present?
        # Prevent assigning owner role via invitation
        if account_role == 'owner'
          render_validation_errors(['Owner role cannot be assigned via invitation. The parent supplier is automatically the owner.'], 'Invitation failed')
          return
        end
        
        options[:supplier_profile_id] = supplier_profile_id
        options[:account_role] = account_role
        options[:permissions] = {
          can_manage_products: supplier_params_data[:can_manage_products] || false,
          can_manage_orders: supplier_params_data[:can_manage_orders] || false,
          can_view_financials: supplier_params_data[:can_view_financials] || false,
          can_manage_users: supplier_params_data[:can_manage_users] || false,
          can_manage_settings: supplier_params_data[:can_manage_settings] || false,
          can_view_analytics: supplier_params_data[:can_view_analytics] || false
        }
      end
      
      service = Invitations::Service.new(@supplier, @current_admin)
      
      if service.send_supplier_invitation(invitation_role, options)
        render_created(
          AdminSupplierSerializer.new(@supplier).as_json,
          "Invitation sent to #{@supplier.email} successfully"
        )
      else
        render_validation_errors(service.errors, 'Failed to send invitation')
      end
    end

    # POST /api/v1/admin/suppliers/:id/resend_invitation
    def resend_invitation
      service = Invitations::Service.new(@supplier, @current_admin)
      
      if service.resend_invitation
        render_success(
          AdminSupplierSerializer.new(@supplier).as_json,
          "Invitation resent to #{@supplier.email}"
        )
      else
        render_validation_errors(service.errors, 'Failed to resend invitation')
      end
    end

    # GET /api/v1/admin/suppliers/:id/stats
    def stats
      service = Suppliers::StatsService.new(@supplier)
      service.call
      
      if service.success?
        render_success(service.stats, 'Supplier statistics retrieved successfully')
      else
        render_error(service.errors.join(', '), :unprocessable_entity)
      end
    end
    
    private
    
    def require_supplier_admin_role!
      require_role!(['super_admin', 'supplier_admin'])
    end
    
    def set_supplier
      @supplier = User.suppliers_only.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('Supplier not found')
    end
    
  end
end

