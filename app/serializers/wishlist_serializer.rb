# frozen_string_literal: true

# Serializer for Wishlist API responses
class WishlistSerializer < BaseSerializer
  def serialize
    wishlist_items = object.wishlist_items.includes(
      product_variant: { product: [:brand, :category, :product_images] }
    )
    
    wishlist_items.map { |item| serialize_item(item) }
  end

  private

  def serialize_item(item)
    variant = item.product_variant
    product = variant.product
    
    {
      id: item.id,
      product_variant: {
        id: variant.id,
        sku: variant.sku,
        price: format_price(variant.price),
        discounted_price: format_price(variant.discounted_price),
        stock_quantity: variant.stock_quantity || 0,
        available_quantity: variant.available_quantity || 0,
        product: {
          id: product.id,
          name: product.name,
          brand: product.brand&.name,
          category: product.category&.name,
          image_url: variant.product_images.first&.image_url || 
                     product.product_variants.first&.product_images&.first&.image_url
        }
      },
      created_at: format_date(item.created_at)
    }
  end
end

