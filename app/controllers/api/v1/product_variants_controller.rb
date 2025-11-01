class Api::V1::ProductVariantsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product
  before_action :set_variant, only: [:update, :destroy]

  # POST /api/v1/products/:product_id/product_variants
  def create
    @variant = @product.product_variants.build(variant_params)
    if @variant.save
      render_created(format_model_data(@variant), 'Product variant created successfully')
    else
      render_validation_errors(@variant.errors.full_messages, 'Product variant creation failed')
    end
  end

  # PUT/PATCH /api/v1/products/:product_id/product_variants/:id
  def update
    if @variant.update(variant_params)
      render_success(format_model_data(@variant), 'Product variant updated successfully')
    else
      render_validation_errors(@variant.errors.full_messages, 'Product variant update failed')
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
    params.require(:product_variant).permit(:sku, :price, :discounted_price, :stock_quantity, :weight_kg)
  end
end