# frozen_string_literal: true

# Refactored ProductsController using Clean Architecture
# Controller → Service → Repository → Model
class Api::V1::ProductsController < ApplicationController
  include SupplierAuthorization
  include PermissionMapper
  include ServiceResponseHandler
  include EagerLoading
  
  resource_type 'products'
  default_includes :brand, :category, :supplier_profile, product_variants: [:product_images]
  
  before_action :authenticate_supplier_request, if: :supplier_route?
  before_action :check_permissions, only: [:create, :update, :destroy], if: -> { @current_supplier_account_user }
  before_action :load_product, only: [:show, :update, :destroy]

  # GET /api/v1/products
  def index
    products = with_eager_loading(scope_supplier_products, additional_includes: product_includes)
    presented_products = products.map { |product| ProductPresenter.new(product).to_api_hash }
    
    render_success(presented_products, 'Products retrieved successfully')
  end

  # GET /api/v1/products/:id
  def show
    render_success(
      ProductPresenter.new(@product).to_api_hash,
      'Product retrieved successfully'
    )
  end

  # POST /api/v1/products
  def create
    service = ProductCreationService.new(
      @current_supplier_account_user.supplier_profile,
      product_params
    )
    
    service.call
    handle_service_response(
      service,
      success_message: 'Product created successfully',
      error_message: 'Product creation failed',
      presenter: ProductPresenter,
      status: :created
    )
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    form = ProductForm.new(
      product_params.merge(supplier_profile_id: @current_supplier_account_user.supplier_profile.id)
    )
    
    if form.update(@product)
      render_success(
        ProductPresenter.new(form.product).to_api_hash,
        'Product updated successfully'
      )
    else
      render_validation_errors(form.errors.full_messages, 'Product update failed')
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    ProductRepository.new.destroy(@product)
    render_no_content('Product deleted successfully')
  end

  private

  def check_permissions
    return unless requires_permission?
    
    permission = permission_for_action
    require_supplier_permission!(permission)
  end

  def load_product
    products_scope = with_eager_loading(scope_supplier_products, additional_includes: product_includes)
    @product = products_scope.find(params[:id])
    
    unless supplier_can_access_resource?(@product)
      render_unauthorized('Access denied: Product belongs to different supplier')
      return
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  def product_params
    # Phase 2: Include Phase 2 fields
    params.require(:product).permit(
      :name, :description, :short_description,
      :category_id, :brand_id, :product_type, :slug,
      :meta_title, :meta_description, :meta_keywords,
      :base_price, :base_discounted_price, :base_mrp,
      :length_cm, :width_cm, :height_cm, :weight_kg,
      :is_featured, :is_bestseller, :is_new_arrival, :is_trending,
      :published_at,
      highlights: [],
      search_keywords: [],
      tags: [],
      attribute_value_ids: [],
      variants_attributes: [
        :sku, :price, :discounted_price, :mrp, :cost_price,
        :stock_quantity, :reserved_quantity, :weight_kg,
        :barcode, :ean_code, :isbn, :currency, :low_stock_threshold,
        image_urls: []
      ]
    )
  end
end
