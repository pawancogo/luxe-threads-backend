# frozen_string_literal: true

# Serializer for Cart API responses
class CartSerializer < BaseSerializer
  def serialize
    cart_items = object.cart_items.includes(
      product_variant: { product: [:brand, :category, product_variants: :product_images] }
    )
    
    {
      cart_items: serialize_items(cart_items),
      total_price: Carts::CalculationService.calculate_total(cart_items),
      item_count: Carts::CalculationService.calculate_item_count(cart_items)
    }
  end

  private

  def serialize_items(cart_items)
    cart_items.map do |item|
      variant = item.product_variant
      product = variant.product
      
      {
        id: item.id,
        product_variant_id: variant.id,
        quantity: item.quantity,
        price: format_price(variant.price),
        discounted_price: format_price(variant.discounted_price),
        subtotal: format_price((variant.discounted_price || variant.price) * item.quantity),
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

