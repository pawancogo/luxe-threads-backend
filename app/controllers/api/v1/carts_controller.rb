class Api::V1::CartsController < ApplicationController
  include ApiFormatters
  include CustomerOnly

  def show
    @cart = current_user.cart || current_user.create_cart
    @cart_items = @cart.cart_items.includes(product_variant: { product: [:brand, :category, product_variants: :product_images] })
    
    total_price = @cart_items.sum do |item|
      (item.product_variant.discounted_price || item.product_variant.price) * item.quantity
    end
    
    render_success(format_cart_data(@cart_items, total_price), 'Cart retrieved successfully')
  end

  private

  def format_cart_data(cart_items, total_price)
    {
      cart_items: cart_items.map { |item| format_cart_item_data(item) },
      total_price: total_price,
      item_count: cart_items.sum(&:quantity)
    }
  end
end