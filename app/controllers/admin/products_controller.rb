class Admin::ProductsController < Admin::BaseController
    before_action :require_product_admin_or_super_admin!
    before_action :enable_date_filter, only: [:index]
    before_action :set_range_filter_options, only: [:index]
    before_action :set_product, only: [:show, :edit, :update, :destroy, :approve, :reject]

    def index
      @status = params[:status] || 'pending'
      @products = Product.includes(:supplier_profile, :category, :brand, :product_variants, verified_by_admin: [])
                         ._search(params, date_range_column: :created_at)
                         .order(created_at: :desc)
      
      # Override status filter if 'all' is selected
      @products = @products.where.not(status: nil) if @status == 'all'
      
      @filters.merge!(@products.filter_with_aggs)
    end

    private

    def set_range_filter_options
      # Enable price range filter for products
      enable_range_filter([
        ['Base Price', 'base_price'],
        ['Min Price', 'min_price'],
        ['Max Price', 'max_price']
      ])
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: 'Product updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      product_id = @product.id
      @product.destroy
      redirect_to admin_products_path, notice: 'Product deleted successfully.'
    end

    def bulk_approve
      product_ids = params[:product_ids] || []
      Product.where(id: product_ids).update_all(
        status: 'active',
        verified_by_admin_id: current_admin.id,
        verified_at: Time.current
      )
      redirect_to admin_products_path, notice: "#{product_ids.count} products approved successfully."
    end

    def bulk_reject
      product_ids = params[:product_ids] || []
      rejection_reason = params[:rejection_reason]
      Product.where(id: product_ids).update_all(
        status: 'rejected',
        verified_by_admin_id: current_admin.id,
        verified_at: Time.current,
        rejection_reason: rejection_reason
      )
      redirect_to admin_products_path, notice: "#{product_ids.count} products rejected successfully."
    end

    def export
      # CSV export functionality
      require 'csv'
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ['ID', 'Name', 'Status', 'Supplier', 'Category', 'Price', 'Created At']
        Product.includes(:supplier_profile, :category).find_each do |product|
          csv << [
            product.id,
            product.name,
            product.status,
            product.supplier_profile&.company_name,
            product.category&.name,
            product.product_variants&.first&.price,
            product.created_at
          ]
        end
      end
      
      send_data csv_data,
                filename: "products_export_#{Time.current.strftime('%Y%m%d')}.csv",
                type: 'text/csv'
    end

    def show
      @product_variants = @product.product_variants
                                  .includes(:product_images, product_variant_attributes: { attribute_value: :attribute_type })
                                  .order(created_at: :desc)
      
      # Filter by SKU search
      if params[:variant_search].present?
        @product_variants = @product_variants.where('sku LIKE ?', "%#{params[:variant_search]}%")
      end
      
      # Filter by status
      if params[:variant_status].present?
        case params[:variant_status]
        when 'available'
          @product_variants = @product_variants.where(is_available: true)
        when 'unavailable'
          @product_variants = @product_variants.where(is_available: false)
        when 'low_stock'
          @product_variants = @product_variants.where(is_low_stock: true)
        when 'out_of_stock'
          @product_variants = @product_variants.where(out_of_stock: true)
        end
      end
      
      @product_variants = @product_variants.page(params[:variant_page])
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

    def product_params
      params.require(:product).permit(:name, :description, :status, :is_featured, :rejection_reason)
    end

    def require_product_admin_or_super_admin!
      unless current_admin&.can_manage_products?
        redirect_to admin_root_path, alert: 'You do not have permission to manage products.'
      end
    end
  end

