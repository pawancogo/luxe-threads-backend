class Api::V1::CartItemsController < ApplicationController
  before_action :set_cart

  def create
    # Find item if it already exists to update quantity
    @cart_item = @cart.cart_items.find_or_initialize_by(product_variant_id: params[:product_variant_id])
    @cart_item.quantity = (@cart_item.quantity || 0) + params[:quantity].to_i
    
    if @cart_item.save
      render json: @cart.cart_items, status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(quantity: params[:quantity].to_i)
      render json: @cart.cart_items
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    render json: @cart.cart_items
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end