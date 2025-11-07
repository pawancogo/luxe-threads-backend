class Admin::SuppliersController < Admin::BaseController
    before_action :require_super_admin!
    before_action :set_supplier, only: [:show, :edit, :update, :destroy, :update_role, :approve, :reject]

    def index
      # Get users with supplier role who own supplier profiles
      @suppliers = User.where(role: 'supplier')
                      .includes(:supplier_profile, :owned_supplier_profiles)
                      ._search(params)
                      .order(:first_name)
      @filters.merge!(@suppliers.filter_with_aggs)
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

