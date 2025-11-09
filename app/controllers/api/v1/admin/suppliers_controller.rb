# frozen_string_literal: true

module Api::V1::Admin
  class SuppliersController < BaseController
    include AdminApiAuthorization
    
    before_action :require_supplier_admin_role!, only: [:index, :show, :update, :destroy, :activate, :deactivate, :suspend, :invite, :resend_invitation]
    before_action :set_supplier, only: [:show, :update, :destroy, :activate, :deactivate, :suspend, :stats, :resend_invitation]
    
    # GET /api/v1/admin/suppliers
    def index
      @suppliers = User.where(role: 'supplier')
                      .includes(:supplier_profile, :owned_supplier_profiles)
                      .order(created_at: :desc)
      
      # Filters
      @suppliers = @suppliers.joins(:supplier_profile).where('supplier_profiles.company_name LIKE ?', "%#{params[:search]}%") if params[:search].present?
      @suppliers = @suppliers.where('users.email LIKE ?', "%#{params[:email]}%") if params[:email].present?
      @suppliers = @suppliers.joins(:supplier_profile).where(supplier_profiles: { verified: params[:verified] == 'true' }) if params[:verified].present?
      @suppliers = @suppliers.where.not(deleted_at: nil) if params[:active] == 'false'
      @suppliers = @suppliers.where(deleted_at: nil) if params[:active] == 'true'
      
      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      @suppliers = @suppliers.page(page).per(per_page)
      
      render_success(format_suppliers_data(@suppliers), 'Suppliers retrieved successfully')
    end
    
    # GET /api/v1/admin/suppliers/:id
    def show
      render_success(format_supplier_detail_data(@supplier), 'Supplier retrieved successfully')
    end
    
    # PATCH /api/v1/admin/suppliers/:id
    def update
      supplier_params_data = params[:supplier] || {}
      
      if @supplier.update(supplier_params_data.permit(:first_name, :last_name, :phone_number, :email))
        # Update supplier profile if provided
        if supplier_params_data[:supplier_profile].present?
          profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
          if profile
            profile.update(supplier_params_data[:supplier_profile].permit(:company_name, :gst_number, :description, :website_url))
          end
        end
        
        log_admin_activity('update', 'Supplier', @supplier.id, @supplier.previous_changes)
        render_success(format_supplier_detail_data(@supplier), 'Supplier updated successfully')
      else
        render_validation_errors(@supplier.errors.full_messages, 'Supplier update failed')
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
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      unless profile
        render_error('Supplier profile not found', 'Supplier must have a profile')
        return
      end
      
      changes = {}
      if @supplier.update(deleted_at: nil)
        changes[:deleted_at] = [@supplier.deleted_at_before_last_save, nil]
      end
      if profile.update(verified: true)
        changes[:verified] = [profile.verified_before_last_save, true]
      end
      
      if changes.any?
        log_admin_activity('update', 'Supplier', @supplier.id, changes)
        render_success(format_supplier_detail_data(@supplier), 'Supplier activated successfully')
      else
        render_validation_errors(@supplier.errors.full_messages + profile.errors.full_messages, 'Supplier activation failed')
      end
    end
    
    # PATCH /api/v1/admin/suppliers/:id/deactivate
    def deactivate
      if @supplier.update(deleted_at: Time.current)
        log_admin_activity('update', 'Supplier', @supplier.id, { deleted_at: [@supplier.deleted_at_before_last_save, Time.current] })
        render_success(format_supplier_detail_data(@supplier), 'Supplier deactivated successfully')
      else
        render_validation_errors(@supplier.errors.full_messages, 'Supplier deactivation failed')
      end
    end
    
    # PATCH /api/v1/admin/suppliers/:id/suspend
    def suspend
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      unless profile
        render_error('Supplier profile not found', 'Supplier must have a profile')
        return
      end
      
      suspension_reason = params[:suspension_reason] || 'Supplier account suspended by admin'
      
      changes = {}
      if @supplier.update(deleted_at: Time.current)
        changes[:deleted_at] = [@supplier.deleted_at_before_last_save, Time.current]
      end
      if profile.update(verified: false)
        changes[:verified] = [profile.verified_before_last_save, false]
      end
      
      if changes.any?
        log_admin_activity('update', 'Supplier', @supplier.id, { **changes, suspension_reason: suspension_reason })
        render_success(format_supplier_detail_data(@supplier), 'Supplier suspended successfully')
      else
        render_validation_errors(@supplier.errors.full_messages + profile.errors.full_messages, 'Supplier suspension failed')
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
      
      service = InvitationService.new(@supplier, @current_admin)
      
      if service.send_supplier_invitation(invitation_role, options)
        render_created(format_supplier_detail_data(@supplier), "Invitation sent to #{@supplier.email} successfully")
      else
        render_validation_errors(service.errors, 'Failed to send invitation')
      end
    end

    # POST /api/v1/admin/suppliers/:id/resend_invitation
    def resend_invitation
      service = InvitationService.new(@supplier, @current_admin)
      
      if service.resend_invitation
        render_success(format_supplier_detail_data(@supplier), "Invitation resent to #{@supplier.email}")
      else
        render_validation_errors(service.errors, 'Failed to resend invitation')
      end
    end

    # GET /api/v1/admin/suppliers/:id/stats
    def stats
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      stats_data = {
        total_products: profile ? profile.products.count : 0,
        active_products: profile ? profile.products.where(status: 'active').count : 0,
        total_orders: profile ? profile.products.joins(:product_variants => :order_items).distinct.count('order_items.order_id') : 0,
        total_revenue: profile ? profile.products.joins(:product_variants => :order_items => :order).where(orders: { status: ['paid', 'shipped', 'delivered'] }).sum('order_items.price * order_items.quantity') : 0,
        verified: profile&.verified || false,
        created_at: @supplier.created_at
      }
      
      render_success(stats_data, 'Supplier statistics retrieved successfully')
    end
    
    private
    
    def require_supplier_admin_role!
      require_role!(['super_admin', 'supplier_admin'])
    end
    
    def set_supplier
      @supplier = User.where(role: 'supplier').find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('Supplier not found')
    end
    
    def format_suppliers_data(suppliers)
      suppliers.map { |supplier| format_supplier_data(supplier) }
    end
    
    def format_supplier_data(supplier)
      profile = supplier.primary_supplier_profile || supplier.supplier_profile
      {
        id: supplier.id,
        email: supplier.email,
        first_name: supplier.first_name,
        last_name: supplier.last_name,
        full_name: supplier.full_name,
        phone_number: supplier.phone_number,
        company_name: profile&.company_name,
        verified: profile&.verified || false,
        is_active: supplier.deleted_at.nil?,
        created_at: supplier.created_at
      }
    end
    
    def format_supplier_detail_data(supplier)
      profile = supplier.primary_supplier_profile || supplier.supplier_profile
      format_supplier_data(supplier).merge(
        gst_number: profile&.gst_number,
        description: profile&.description,
        website_url: profile&.website_url,
        supplier_tier: profile&.supplier_tier,
        deleted_at: supplier.deleted_at,
        updated_at: supplier.updated_at
      )
    end
  end
end

