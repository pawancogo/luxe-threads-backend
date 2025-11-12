# frozen_string_literal: true

# Refactored CartItemsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::CartItemsController < ApplicationController
  include CustomerOnly
  include ServiceResponseHandler
  
  before_action :set_cart

  def create
      service = Carts::ItemCreationService.new(
      @cart,
      params[:product_variant_id],
      params[:quantity]
    )
    service.call
    
    if service.success?
      render_cart_response('Item added to cart successfully', :created)
    else
      render_validation_errors(service.errors, 'Failed to add item to cart')
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    service = Carts::ItemUpdateService.new(@cart_item, params[:quantity])
    service.call
    
    if service.success?
      render_cart_response('Cart item updated successfully')
    else
      render_validation_errors(service.errors, 'Failed to update cart item')
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    
    service = Carts::ItemDeletionService.new(@cart_item)
    service.call
    
    if service.success?
      render_cart_response('Item removed from cart successfully')
    else
      render_validation_errors(service.errors, 'Failed to remove item from cart')
    end
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def render_cart_response(message, status = :ok)
    cart = Cart.with_cart_items.find(@cart.id)
    render_success(
      CartSerializer.new(cart).as_json,
      message,
      status
    )
  end
end