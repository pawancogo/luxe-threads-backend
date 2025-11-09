# frozen_string_literal: true

# Shared API response formatters
# Consolidates duplicate formatting logic across controllers
module ApiFormatters
  extend ActiveSupport::Concern

  # Format product variant data (used in cart, wishlist, orders)
  def format_product_variant_data(variant)
    product = variant.product
    {
      variant_id: variant.id,
      sku: variant.sku,
      price: variant.price,
      discounted_price: variant.discounted_price,
      stock_quantity: variant.stock_quantity,
      available_quantity: variant.available_quantity || 0,
      product_name: product.name,
      product_id: product.id,
      brand_name: product.brand&.name,
      category_name: product.category&.name,
      image_url: variant.product_images.first&.image_url || 
                 product.product_variants.first&.product_images&.first&.image_url
    }
  end

  # Format cart item data
  def format_cart_item_data(cart_item)
    variant_data = format_product_variant_data(cart_item.product_variant)
    {
      cart_item_id: cart_item.id,
      quantity: cart_item.quantity,
      product_variant: variant_data,
      subtotal: (cart_item.product_variant.discounted_price || cart_item.product_variant.price) * cart_item.quantity
    }
  end

  # Format wishlist item data
  def format_wishlist_item_data(wishlist_item)
    {
      wishlist_item_id: wishlist_item.id,
      product_variant: format_product_variant_data(wishlist_item.product_variant)
    }
  end

  # Format address data (used in orders, shipping)
  def format_address_data(address)
    return nil unless address
    
    {
      id: address.id,
      full_name: address.full_name,
      phone_number: address.phone_number,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      state: address.state,
      postal_code: address.postal_code,
      country: address.country
    }
  end

  # Format order item summary (for list views)
  def format_order_item_summary(order_item)
    {
      id: order_item.id,
      product_name: order_item.product_name || order_item.product_variant.product.name,
      quantity: order_item.quantity,
      price: order_item.final_price || order_item.price_at_purchase,
      image_url: order_item.product_image_url || 
                 order_item.product_variant.product_images.first&.image_url
    }
  end

  # Format order item detail (for detail views)
  def format_order_item_detail(order_item)
    variant = order_item.product_variant
    product = variant.product
    {
      id: order_item.id,
      product_variant_id: variant.id,
      product_name: order_item.product_name || product.name,
      sku: variant.sku,
      quantity: order_item.quantity,
      price_at_purchase: order_item.price_at_purchase,
      discounted_price: order_item.discounted_price,
      final_price: order_item.final_price,
      subtotal: order_item.subtotal,
      fulfillment_status: order_item.fulfillment_status,
      image_url: order_item.product_image_url || variant.product_images.first&.image_url,
      brand_name: product.brand&.name,
      category_name: product.category&.name
    }
  end
end



