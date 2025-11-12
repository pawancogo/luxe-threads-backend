# frozen_string_literal: true

# Explicitly require custom classes (fallback until autoloading is fixed)
require_dependency File.join(Rails.root, 'app/forms/product_variant_form')
require_dependency File.join(Rails.root, 'config/initializers/color_hex_map')

# Refactored ProductVariantsController using new architecture
# Uses Form objects instead of direct model manipulation
class Api::V1::ProductVariantsController < ApplicationController
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!
  before_action :set_product
  before_action :set_variant, only: [:update, :destroy]

  # POST /api/v1/products/:product_id/product_variants
  def create
      service = Products::VariantCreationService.new(@product, variant_params)
    service.call
    
    if service.success?
      render_created(
        ProductVariantSerializer.new(service.variant).as_json,
        'Product variant created successfully'
      )
    else
      render_validation_errors(service.errors, 'Product variant creation failed')
    end
  end

  # PUT/PATCH /api/v1/products/:product_id/product_variants/:id
  def update
      service = Products::VariantUpdateService.new(@variant, variant_params)
    service.call
    
    if service.success?
      render_success(
        ProductVariantSerializer.new(service.variant).as_json,
        'Product variant updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Product variant update failed')
    end
  end

  # DELETE /api/v1/products/:product_id/product_variants/:id
  def destroy
    @variant.destroy
    render_no_content('Product variant deleted successfully')
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
    @product = current_user.supplier_profile.products.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  def set_variant
    @variant = @product.product_variants.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product variant not found')
  end

  def variant_params
    params.require(:product_variant).permit(
      :sku,
      :price,
      :discounted_price,
      :stock_quantity,
      :weight_kg,
      image_urls: [],
      attribute_value_ids: []
    )
  end

end
