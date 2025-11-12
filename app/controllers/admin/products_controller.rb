# frozen_string_literal: true

# Refactored Admin::ProductsController using Clean Architecture
# Controller → Service → Model → Presenter → View
class Admin::ProductsController < Admin::BaseController
    include EagerLoading
    before_action :require_product_admin_or_super_admin!
    before_action :enable_date_filter, only: [:index]
    before_action :set_range_filter_options, only: [:index]
    before_action :set_product, only: [:show, :edit, :update, :destroy, :approve, :reject]

    def index
      @status = params[:status] || 'pending'
      
      search_options = { date_range_column: :created_at }
      search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
      
      service = Products::AdminHtmlListingService.new(Product.all, params, search_options)
      service.call
      
      if service.success?
        @products = service.products
        @filters.merge!(service.filters)
        @product_presenters = @products.map { |product| ProductPresenter.new(product) }
      else
        @products = Product.none
        @filters = {}
        @product_presenters = []
        flash[:alert] = service.errors.join(', ')
      end
    end

  def show
    @product_presenter = ProductPresenter.new(@product)
    
    service = Products::VariantListingService.new(@product.product_variants, params)
    service.call
    
    if service.success?
      @product_variants = service.variants
    else
      @product_variants = ProductVariant.none
    end
  end

  def edit
    @product_presenter = ProductPresenter.new(@product)
  end

  def update
    service = Products::UpdateService.new(@product, product_params)
    service.call
    
    if service.success?
      redirect_to admin_product_path(@product), notice: 'Product updated successfully.'
    else
      @product_presenter = ProductPresenter.new(@product)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service = Products::DeletionService.new(@product)
    service.call
    
    if service.success?
      redirect_to admin_products_path, notice: 'Product deleted successfully.'
    else
      redirect_to admin_products_path, alert: service.errors.first || 'Failed to delete product'
    end
  end

  def bulk_approve
    service = Products::BulkApprovalService.new(params[:product_ids], current_admin)
    service.call
    
    if service.success?
      count = service.result.count
      redirect_to admin_products_path, notice: "#{count} products approved successfully."
    else
      redirect_to admin_products_path, alert: service.errors.join(', ')
    end
  end

  def bulk_reject
    service = Products::BulkRejectionService.new(
      params[:product_ids],
      current_admin,
      rejection_reason: params[:rejection_reason]
    )
    service.call
    
    if service.success?
      count = service.result.count
      redirect_to admin_products_path, notice: "#{count} products rejected successfully."
    else
      redirect_to admin_products_path, alert: service.errors.join(', ')
    end
  end

  def export
    service = Products::ExportService.new(Product.all)
    service.call
    
    if service.success?
      send_data service.result,
                filename: service.filename,
                type: 'text/csv'
    else
      redirect_to admin_products_path, alert: 'Failed to export products.'
    end
  end

    def approve
    service = Products::ApprovalService.new(@product, current_admin)
    service.call
    
    if service.success?
        redirect_to admin_product_path(@product), notice: 'Product approved successfully.'
      else
      redirect_to admin_product_path(@product), alert: service.errors.join(', ')
      end
    end

    def reject
    service = Products::RejectionService.new(
      @product,
      current_admin,
      rejection_reason: params[:rejection_reason]
    )
    service.call
    
    if service.success?
        redirect_to admin_product_path(@product), notice: 'Product rejected successfully.'
      else
      redirect_to admin_product_path(@product), alert: service.errors.join(', ')
      end
    end

    private

    def set_range_filter_options
      enable_range_filter(:base_price)
    end

    def set_product
      @product = with_eager_loading(Product.all, additional_includes: product_includes).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_products_path, alert: 'Product not found.'
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

