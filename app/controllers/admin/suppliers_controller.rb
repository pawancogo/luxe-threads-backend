class Admin::SuppliersController < Admin::BaseController
    before_action :require_super_admin!
    before_action :set_supplier, only: [:show, :edit, :update, :destroy, :update_role, :approve, :reject, :resend_invitation]

    def index
      # Get users with supplier role who own supplier profiles
      # Exclude role from params to avoid double filtering since we already filter by role
      search_params = params.except(:role, :controller, :action).permit(:search, :per_page, :page, :is_active, :email_verified, :date_range, :min, :max)
      search_options = {}
      search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
      
      @suppliers = User.where(role: 'supplier')
                      .includes(:supplier_profile, :owned_supplier_profiles)
                      ._search(search_params, **search_options)
                      .order(:first_name)
      
      # Merge filters (this will include aggregations)
      begin
        filter_aggs = @suppliers.filter_with_aggs if @suppliers.respond_to?(:filter_with_aggs)
        @filters.merge!(filter_aggs) if filter_aggs.present?
      rescue => e
        Rails.logger.error "Error merging filters: #{e.message}"
        @filters ||= { search: [nil] }
      end
    end

    def show
      @supplier_profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
    end

    def new
      @supplier = User.new(role: 'supplier')
      @supplier.build_supplier_profile
    end

    def create
      @supplier = User.new(supplier_params.except(:supplier_profile_attributes).merge(role: 'supplier'))
      
      if @supplier.save
        # Create supplier profile if attributes provided
        if supplier_params[:supplier_profile_attributes].present?
          profile = @supplier.build_supplier_profile(supplier_params[:supplier_profile_attributes])
          profile.owner_id = @supplier.id
          profile.user_id = @supplier.id
          profile.save
          
          # Create supplier account user (owner)
          SupplierAccountUser.create!(
            supplier_profile: profile,
            user: @supplier,
            role: 'owner',
            status: 'active',
            can_manage_products: true,
            can_manage_orders: true,
            can_view_financials: true,
            can_manage_users: true,
            can_manage_settings: true,
            can_view_analytics: true,
            accepted_at: Time.current
          )
        end
        
        redirect_to admin_suppliers_path, notice: 'Supplier created successfully.'
      else
        @supplier.build_supplier_profile
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @supplier_profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      @supplier.build_supplier_profile unless @supplier_profile
    end

    def update
      if @supplier.update(supplier_params.except(:supplier_profile_attributes))
        # Update supplier profile
        if supplier_params[:supplier_profile_attributes].present?
          profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
          if profile
            profile.update(supplier_params[:supplier_profile_attributes])
          else
            profile = @supplier.create_supplier_profile(supplier_params[:supplier_profile_attributes])
            profile.update(owner_id: @supplier.id, user_id: @supplier.id)
          end
        end
        
        redirect_to admin_suppliers_path, notice: 'Supplier updated successfully.'
      else
        @supplier.build_supplier_profile unless @supplier.supplier_profile
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @supplier.destroy
      redirect_to admin_suppliers_path, notice: 'Supplier deleted successfully.'
    end

    def update_role
      # Note: Role is now 'supplier' for all, but we can update supplier_tier
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      if profile && params[:tier].present?
        if profile.update(supplier_tier: params[:tier])
          redirect_to admin_supplier_path(@supplier), notice: 'Supplier tier updated successfully.'
        else
          redirect_to admin_supplier_path(@supplier), alert: 'Failed to update supplier tier.'
        end
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Invalid tier or supplier profile not found.'
      end
    end

    def approve
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      unless profile
        redirect_to admin_supplier_path(@supplier), alert: 'Supplier profile not found.'
        return
      end

      if profile.update(verified: true)
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier approved successfully.'
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Failed to approve supplier.'
      end
    end

    def reject
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      unless profile
        redirect_to admin_supplier_path(@supplier), alert: 'Supplier profile not found.'
        return
      end

      if profile.update(verified: false)
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier rejected successfully.'
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Failed to reject supplier.'
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
      
      service = InvitationService.new(@supplier, current_admin)
      
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
      service = InvitationService.new(@supplier, current_admin)
      
      if service.resend_invitation
        redirect_to admin_suppliers_path, notice: "Invitation resent to #{@supplier.email}."
      else
        redirect_to admin_suppliers_path, alert: "Failed to resend invitation: #{service.errors.join(', ')}"
      end
    end

    def bulk_action
      supplier_ids = params[:supplier_ids]&.split(',') || []
      action = params[:bulk_action]
      
      return redirect_to admin_suppliers_path, alert: 'Please select at least one supplier.' if supplier_ids.empty?
      
      suppliers = User.where(id: supplier_ids, role: 'supplier').includes(:supplier_profile)
      count = 0
      
      case action
      when 'verify'
        suppliers.each do |supplier|
          profile = supplier.primary_supplier_profile || supplier.supplier_profile
          if profile
            profile.update(verified: true)
            count += 1
          end
        end
        notice = "#{count} supplier(s) verified successfully."
      when 'unverify'
        suppliers.each do |supplier|
          profile = supplier.primary_supplier_profile || supplier.supplier_profile
          if profile
            profile.update(verified: false)
            count += 1
          end
        end
        notice = "#{count} supplier(s) unverified successfully."
      when 'delete'
        count = suppliers.count
        suppliers.destroy_all
        notice = "#{count} supplier(s) deleted successfully."
      else
        return redirect_to admin_suppliers_path, alert: 'Invalid action.'
      end
      
      redirect_to admin_suppliers_path, notice: notice
    end

    private

    def set_supplier
      @supplier = User.where(role: 'supplier').find(params[:id])
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

