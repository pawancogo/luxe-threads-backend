# frozen_string_literal: true

# Refactored Admin::SuppliersController using Clean Architecture
# Controller → Service → Model → Presenter → View
class Admin::SuppliersController < Admin::BaseController
  before_action :require_super_admin!
  before_action :set_supplier, only: [:show, :edit, :update, :destroy, :update_role, :approve, :reject, :resend_invitation, :update_status, :stats, :suspend]

  def index
    search_params = params.except(:role, :controller, :action).permit(:search, :per_page, :page, :is_active, :email_verified, :date_range, :min, :max)
    search_options = {}
    search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
    
    @suppliers = User.suppliers_only
                     .includes(:supplier_profile, :owned_supplier_profiles)
                     ._search(search_params, **search_options)
                     .order(:first_name)
    
    # Merge filters
    begin
      filter_aggs = @suppliers.filter_with_aggs if @suppliers.respond_to?(:filter_with_aggs)
      @filters.merge!(filter_aggs) if filter_aggs.present?
    rescue => e
      Rails.logger.error "Error merging filters: #{e.message}"
      @filters ||= { search: [nil] }
    end
    
    @supplier_presenters = @suppliers.map { |supplier| SupplierPresenter.new(supplier) }
  end

  def show
    @supplier_profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
    @supplier_presenter = SupplierPresenter.new(@supplier)
  end

  def new
    @supplier = User.new(role: 'supplier')
    @supplier.build_supplier_profile
  end

  def create
    service = Suppliers::AdminCreationService.new(supplier_params, current_admin)
    service.call
    
    if service.success?
      redirect_to admin_suppliers_path, notice: 'Supplier created successfully.'
    else
      @supplier = service.supplier || User.new(role: 'supplier')
      @supplier.build_supplier_profile unless @supplier.supplier_profile
      flash.now[:alert] = service.errors.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @supplier_profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
    @supplier.build_supplier_profile unless @supplier_profile
    @supplier_presenter = SupplierPresenter.new(@supplier)
  end

  def update
    service = Suppliers::UpdateService.new(@supplier, supplier_params)
    service.call
    
    if service.success?
      redirect_to admin_suppliers_path, notice: 'Supplier updated successfully.'
    else
      @supplier.build_supplier_profile unless @supplier.supplier_profile
      @supplier_presenter = SupplierPresenter.new(@supplier)
      flash.now[:alert] = service.errors.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service = Suppliers::DeletionService.new(@supplier)
    service.call
    
    if service.success?
      redirect_to admin_suppliers_path, notice: 'Supplier deleted successfully.'
    else
      redirect_to admin_suppliers_path, alert: service.errors.first || 'Failed to delete supplier'
    end
  end

  def update_role
    service = Suppliers::TierUpdateService.new(@supplier, params[:tier])
    service.call
    
    if service.success?
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier tier updated successfully.'
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

  def approve
    service = Suppliers::ApprovalService.new(@supplier, admin: current_admin)
    service.call
    
    if service.success?
      redirect_to admin_supplier_path(@supplier), notice: 'Supplier approved successfully.'
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

  def reject
    service = Suppliers::RejectionService.new(@supplier, admin: current_admin)
    service.call
    
    if service.success?
      redirect_to admin_supplier_path(@supplier), notice: 'Supplier rejected successfully.'
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

    # Invitation flow
    def invite
      @supplier = User.new(role: 'supplier')
    end

    def send_invitation
      @supplier = User.find_or_initialize_by(email: params[:user][:email])
      invitation_type = params[:user][:invitation_type] || 'parent'
      invitation_role = params[:user][:invitation_role] || 'supplier'
      supplier_profile_id = params[:user][:supplier_profile_id]
      account_role = params[:user][:account_role] || 'staff'
      
      # Build options for child supplier invitation
      options = {}
      if invitation_type == 'child' && supplier_profile_id.present?
        # Prevent assigning owner role via invitation
        if account_role == 'owner'
          @errors = ['Owner role cannot be assigned via invitation. The parent supplier is automatically the owner.']
          @supplier = User.new(email: params[:user][:email], role: 'supplier')
          @supplier_profiles = SupplierProfile.includes(:owner).active.order(:company_name)
          render :invite, status: :unprocessable_entity
          return
        end
        
        options[:supplier_profile_id] = supplier_profile_id
        options[:account_role] = account_role
        options[:permissions] = {
          can_manage_products: params[:user][:can_manage_products] == '1',
          can_manage_orders: params[:user][:can_manage_orders] == '1',
          can_view_financials: params[:user][:can_view_financials] == '1',
          can_manage_users: params[:user][:can_manage_users] == '1',
          can_manage_settings: params[:user][:can_manage_settings] == '1',
          can_view_analytics: params[:user][:can_view_analytics] == '1'
        }
      end
      
      service = Invitations::Service.new(@supplier, current_admin)
      
      if service.send_supplier_invitation(invitation_role, options)
        invitation_type_text = invitation_type == 'child' ? 'child supplier' : 'parent supplier'
        redirect_to admin_suppliers_path, notice: "Invitation sent to #{@supplier.email} as #{invitation_type_text} successfully."
      else
        @errors = service.errors
        @supplier = User.new(email: params[:user][:email], role: 'supplier') # Reset for form
        @supplier_profiles = SupplierProfile.includes(:owner).active.order(:company_name)
        render :invite, status: :unprocessable_entity
      end
    end

    def resend_invitation
      service = Invitations::Service.new(@supplier, current_admin)
      
      if service.resend_invitation
        redirect_to admin_suppliers_path, notice: "Invitation resent to #{@supplier.email}."
      else
        redirect_to admin_suppliers_path, alert: "Failed to resend invitation: #{service.errors.join(', ')}"
      end
    end

  def update_status
    service = Suppliers::StatusUpdateService.new(
      @supplier,
      params[:status],
      admin: current_admin,
      suspension_reason: params[:suspension_reason]
    )
    service.call
    
    if service.success?
      notice = case params[:status]
      when 'active' then 'Supplier activated successfully.'
      when 'inactive' then 'Supplier deactivated successfully.'
      when 'suspended' then 'Supplier suspended successfully.'
      end
      redirect_to admin_supplier_path(@supplier), notice: notice
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

  def stats
    service = Suppliers::StatsService.new(@supplier)
    service.call
    
    if service.success?
      @stats = service.result
      respond_to do |format|
        format.html { render :stats }
        format.json { render json: @stats }
      end
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

  def suspend
    service = Suppliers::StatusUpdateService.new(
      @supplier,
      'suspended',
      admin: current_admin,
      suspension_reason: params[:suspension_reason]
    )
    service.call
    
    if service.success?
      redirect_to admin_supplier_path(@supplier), notice: 'Supplier suspended successfully.'
    else
      redirect_to admin_supplier_path(@supplier), alert: service.errors.join(', ')
    end
  end

  def bulk_action
    service = Suppliers::BulkActionService.new(
      params[:supplier_ids]&.split(','),
      params[:bulk_action],
      admin: current_admin
    )
    service.call
    
    if service.success?
      count = service.result.count
      action = params[:bulk_action]
      notice = case action
      when 'verify' then "#{count} supplier(s) verified successfully."
      when 'unverify' then "#{count} supplier(s) unverified successfully."
      when 'delete' then "#{count} supplier(s) deleted successfully."
      end
      redirect_to admin_suppliers_path, notice: notice
    else
      redirect_to admin_suppliers_path, alert: service.errors.join(', ')
    end
  end

  private

  def set_supplier
    @supplier = User.suppliers_only.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_suppliers_path, alert: 'Supplier not found.'
  end

  def supplier_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone_number, :password, :password_confirmation,
      supplier_profile_attributes: [:id, :company_name, :gst_number, :description, :website_url, :verified, :supplier_tier]
    )
  end
end

