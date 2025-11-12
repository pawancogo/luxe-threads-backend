# frozen_string_literal: true

# Service for calculating cart totals
module Carts
  class CalculationService
    def self.calculate_total(cart_items)
      cart_items.sum do |item|
        variant = item.product_variant
        price = variant.discounted_price || variant.price
        price * item.quantity
      end
    end

    def self.calculate_item_count(cart_items)
      cart_items.sum(&:quantity)
    end

    def self.format_cart_response(cart_items)
      total_price = calculate_total(cart_items)
      item_count = calculate_item_count(cart_items)
      
      {
        cart_items: cart_items.map { |item| format_cart_item(item) },
        total_price: total_price,
        item_count: item_count
      }
    end

    private

    def self.format_cart_item(item)
      variant = item.product_variant
      product = variant.product
      
      {
        id: item.id,
        product_variant_id: variant.id,
        quantity: item.quantity,
        price: variant.price.to_f,
        discounted_price: variant.discounted_price&.to_f,
        subtotal: (variant.discounted_price || variant.price) * item.quantity,
        product: {
          id: product.id,
          name: product.name,
          brand: product.brand&.name,
          category: product.category&.name,
          image_url: variant.product_images.first&.image_url
        }
      }
    end
  end
end

