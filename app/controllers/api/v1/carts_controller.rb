class Api::V1::CartsController < ApplicationController
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
      cart_items: cart_items.map do |item|
        variant = item.product_variant
        product = variant.product
        {
          cart_item_id: item.id,
          quantity: item.quantity,
          product_variant: {
            variant_id: variant.id,
            sku: variant.sku,
            price: variant.price,
            discounted_price: variant.discounted_price,
            stock_quantity: variant.stock_quantity,
            product_name: product.name,
            product_id: product.id,
            brand_name: product.brand.name,
            category_name: product.category.name,
            image_url: variant.product_images.first&.image_url || product.product_variants.first&.product_images&.first&.image_url
          },
          subtotal: (variant.discounted_price || variant.price) * item.quantity
        }
      end,
      total_price: total_price,
      item_count: cart_items.sum(&:quantity)
    }
  end
end