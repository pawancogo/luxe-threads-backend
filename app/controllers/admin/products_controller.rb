module Admin
  class ProductsController < BaseController
    before_action :require_product_admin_or_super_admin!
    before_action :set_product, only: [:show, :approve, :reject]

    def index
      @status = params[:status] || 'pending'
      @products = Product.includes(:supplier_profile, :category, :brand, :product_variants, verified_by_admin: [])
                         .order(created_at: :desc)
      
      # Filter by status if specified (not 'all' or blank)
      if @status.present? && @status != 'all'
        @products = @products.where(status: @status)
      end
    end

    def show
      @product_variants = @product.product_variants.includes(:product_images)
    end

    def approve
      if @product.update(
        status: :active,
        verified_by_admin_id: current_admin.id,
        verified_at: Time.current
      )
        redirect_to admin_product_path(@product), notice: 'Product approved successfully.'
      else
        redirect_to admin_product_path(@product), alert: 'Failed to approve product.'
      end
    end

    def reject
      rejection_reason = params[:rejection_reason]
      
      if @product.update(
        status: :rejected,
        verified_by_admin_id: current_admin.id,
        verified_at: Time.current
      )
        # Store rejection reason in a note or separate table if needed
        # For now, we'll use a simple approach
        redirect_to admin_product_path(@product), notice: 'Product rejected successfully.'
      else
        redirect_to admin_product_path(@product), alert: 'Failed to reject product.'
      end
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def require_product_admin_or_super_admin!
      unless current_admin&.can_manage_products?
        redirect_to admin_dashboard_path, alert: 'You do not have permission to manage products.'
      end
    end
  end
end

