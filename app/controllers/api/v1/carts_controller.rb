class Api::V1::CartsController < ApplicationController
  def show
    @cart = current_user.cart
    render json: @cart.cart_items.includes(product_variant: { product: :brand })
  end
end