# frozen_string_literal: true

# Explicitly require custom classes (fallback until autoloading is fixed)
# Using require_dependency ensures files reload in development
require_dependency File.join(Rails.root, 'app/repositories/product_repository')
require_dependency File.join(Rails.root, 'app/presenters/product_presenter')
require_dependency File.join(Rails.root, 'app/forms/product_form')
require_dependency File.join(Rails.root, 'app/queries/product_query')
require_dependency File.join(Rails.root, 'app/services/product_creation_service')

# Refactored ProductsController using new architecture
# Uses Form objects, Query objects, Repositories, and Presenters
class Api::V1::ProductsController < ApplicationController
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /api/v1/products
  def index
    products = ::ProductRepository.new
      .all_for_supplier_profile(current_user.supplier_profile.id)
    
    presented_products = products.map { |product| ::ProductPresenter.new(product).to_api_hash }
    
    render_success(presented_products, 'Products retrieved successfully')
  end

  # GET /api/v1/products/:id
  def show
    presenter = ::ProductPresenter.new(@product)
    render_success(presenter.to_api_hash, 'Product retrieved successfully')
  end

  # POST /api/v1/products
  def create
    service = ::ProductCreationService.new(
      current_user.supplier_profile,
      product_params
    )
    
    result = service.call
    
    if service.success?
      presenter = ::ProductPresenter.new(service.product)
      render_created(presenter.to_api_hash, 'Product created successfully')
    else
      render_validation_errors(service.errors, 'Product creation failed')
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    form = ::ProductForm.new(product_params.merge(
      supplier_profile_id: current_user.supplier_profile.id
    ))
    
    if form.update(@product)
      presenter = ::ProductPresenter.new(form.product)
      render_success(presenter.to_api_hash, 'Product updated successfully')
    else
      render_validation_errors(form.errors.full_messages, 'Product update failed')
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    repository = ::ProductRepository.new
    repository.destroy(@product)
    render_no_content('Product deleted successfully')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

  def set_product
    repository = ::ProductRepository.new
    @product = repository.find_by_supplier_profile(
      current_user.supplier_profile.id,
      params[:id]
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :category_id,
      :brand_id,
      attribute_value_ids: [],
      variants_attributes: [
        :sku,
        :price,
        :discounted_price,
        :stock_quantity,
        :weight_kg,
        image_urls: []
      ]
    )
  end
end
