class Api::V1::ProductsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /api/v1/products
  def index
    @products = current_user.supplier_profile.products
    render json: @products
  end

  # GET /api/v1/products/:id
  def show
    render json: @product
  end

  # POST /api/v1/products
  def create
    @product = current_user.supplier_profile.products.build(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
  end

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def set_product
    @product = current_user.supplier_profile.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :brand_id)
  end
end