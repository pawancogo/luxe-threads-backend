class Api::V1::ProductVariantsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product

  # POST /api/v1/products/:product_id/product_variants
  def create
    @variant = @product.product_variants.build(variant_params)
    if @variant.save
      render json: @variant, status: :created
    else
      render json: @variant.errors, status: :unprocessable_entity
    end
  end
  
  # ... implement update and destroy actions similarly ...

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def set_product
    @product = current_user.supplier_profile.products.find(params[:product_id])
  end

  def variant_params
    params.require(:product_variant).permit(:sku, :price, :stock_quantity, :weight_kg, images: [])
  end
end