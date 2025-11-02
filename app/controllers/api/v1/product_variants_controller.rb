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
    form = ProductVariantForm.new(
      variant_params.merge(product_id: @product.id)
    )
    
    if form.save
      render_created(format_variant_data(form.variant), 'Product variant created successfully')
    else
      render_validation_errors(form.errors.full_messages, 'Product variant creation failed')
    end
  end

  # PUT/PATCH /api/v1/products/:product_id/product_variants/:id
  def update
    form = ProductVariantForm.new(
      variant_params.merge(product_id: @product.id)
    )
    
    if form.update(@variant)
      render_success(format_variant_data(form.variant), 'Product variant updated successfully')
    else
      render_validation_errors(form.errors.full_messages, 'Product variant update failed')
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

  def format_variant_data(variant)
    {
      id: variant.id,
      sku: variant.sku,
      price: variant.price.to_f,
      discounted_price: variant.discounted_price&.to_f,
      stock_quantity: variant.stock_quantity,
      weight_kg: variant.weight_kg&.to_f,
      available: variant.available?,
      current_price: variant.current_price.to_f,
      images: variant.product_images.order(:display_order).map do |image|
        {
          id: image.id,
          url: image.image_url,
          alt_text: image.alt_text,
          display_order: image.display_order
        }
      end,
      attributes: variant.product_variant_attributes.includes(attribute_value: :attribute_type).map do |pva|
        attr_data = {
          attribute_type: pva.attribute_value.attribute_type.name,
          attribute_value: pva.attribute_value.value
        }
        
        # Add color hex code if this is a color attribute
        if pva.attribute_value.attribute_type.name.downcase == 'color'
          hex_code = ColorHexMap.hex_for(pva.attribute_value.value)
          attr_data[:hex_code] = hex_code if hex_code
        end
        
        attr_data
      end,
      created_at: variant.created_at.iso8601,
      updated_at: variant.updated_at.iso8601
    }
  end
end
