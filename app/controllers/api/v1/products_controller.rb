class Api::V1::ProductsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /api/v1/products
  def index
    @products = current_user.supplier_profile.products
    render_success(format_collection_data(@products), 'Products retrieved successfully')
  end

  # GET /api/v1/products/:id
  def show
    render_success(format_model_data(@product), 'Product retrieved successfully')
  end

  # POST /api/v1/products
  def create
    @product = current_user.supplier_profile.products.build(product_params)
    if @product.save
      render_created(format_model_data(@product), 'Product created successfully')
    else
      render_validation_errors(@product.errors.full_messages, 'Product creation failed')
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    if @product.update(product_params)
      render_success(format_model_data(@product), 'Product updated successfully')
    else
      render_validation_errors(@product.errors.full_messages, 'Product update failed')
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
    render_no_content('Product deleted successfully')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def set_product
    @product = current_user.supplier_profile.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :brand_id)
  end
end