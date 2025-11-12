# frozen_string_literal: true

# Refactored CartsController using Clean Architecture
# Controller → Model → Serializer
class Api::V1::CartsController < ApplicationController
  include CustomerOnly

  def show
    cart = current_user.cart || current_user.create_cart
    cart = Cart.with_cart_items.find(cart.id)
    
    render_success(
      CartSerializer.new(cart).as_json,
      'Cart retrieved successfully'
    )
  end
end