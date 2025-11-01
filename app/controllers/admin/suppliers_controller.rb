module Admin
  class SuppliersController < BaseController
    before_action :require_super_admin!
    before_action :set_supplier, only: [:show, :edit, :update, :destroy, :update_role, :approve, :reject]

    def index
      @suppliers = Supplier.includes(:supplier_profile).all.order(:role, :first_name)
    end

    def show
      @supplier_profile = @supplier.supplier_profile
    end

    def new
      @supplier = Supplier.new
      @supplier.build_supplier_profile
    end

    def create
      @supplier = Supplier.new(supplier_params.except(:supplier_profile_attributes))
      
      if @supplier.save
        # Create supplier profile if attributes provided
        if supplier_params[:supplier_profile_attributes].present?
          @supplier.create_supplier_profile(supplier_params[:supplier_profile_attributes])
        end
        
        redirect_to admin_suppliers_path, notice: 'Supplier created successfully.'
      else
        @supplier.build_supplier_profile
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @supplier.build_supplier_profile unless @supplier.supplier_profile
    end

    def update
      if @supplier.update(supplier_params.except(:supplier_profile_attributes))
        # Update supplier profile
        if supplier_params[:supplier_profile_attributes].present?
          if @supplier.supplier_profile
            @supplier.supplier_profile.update(supplier_params[:supplier_profile_attributes])
          else
            @supplier.create_supplier_profile(supplier_params[:supplier_profile_attributes])
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
      if @supplier.update(role: params[:role])
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier role updated successfully.'
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Failed to update supplier role.'
      end
    end

    def approve
      unless @supplier.supplier_profile
        redirect_to admin_supplier_path(@supplier), alert: 'Supplier profile not found.'
        return
      end

      if @supplier.supplier_profile.update(verified: true)
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier approved successfully.'
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Failed to approve supplier.'
      end
    end

    def reject
      unless @supplier.supplier_profile
        redirect_to admin_supplier_path(@supplier), alert: 'Supplier profile not found.'
        return
      end

      if @supplier.supplier_profile.update(verified: false)
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier rejected successfully.'
      else
        redirect_to admin_supplier_path(@supplier), alert: 'Failed to reject supplier.'
      end
    end

    private

    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    def supplier_params
      params.require(:supplier).permit(
        :first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :role,
        supplier_profile_attributes: [:id, :company_name, :gst_number, :description, :website_url, :verified]
      )
    end
  end
end


