# frozen_string_literal: true

# Serializer for supplier order responses (grouped by order)
class SupplierOrderSerializer < BaseSerializer
  attributes :order_id, :order_number, :order_date, :customer_name, :customer_email,
             :status, :payment_status, :total_amount, :currency, :tracking_number,
             :tracking_url, :estimated_delivery_date, :shipping_address,
             :status_history, :items

  def order_id
    object[:order].id
  end

  def order_number
    object[:order].order_number || object[:order].id.to_s.rjust(8, '0')
  end

  def order_date
    object[:order].created_at.iso8601
  end

  def customer_name
    object[:order].user.full_name
  end

  def customer_email
    object[:order].user.email
  end

  def status
    object[:order].status
  end

  def payment_status
    object[:order].payment_status
  end

  def total_amount
    object[:order].total_amount
  end

  def currency
    object[:order].currency || 'INR'
  end

  def tracking_number
    object[:order].tracking_number
  end

  def tracking_url
    object[:order].tracking_url
  end

  def estimated_delivery_date
    object[:order].estimated_delivery_date&.iso8601
  end

  def shipping_address
    return nil unless object[:order].shipping_address
    
    address = object[:order].shipping_address
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

  def status_history
    object[:order].status_history_array
  end

  def items
    object[:items].map do |order_item|
      variant = order_item.product_variant
      product = variant.product
      
      {
        order_item_id: order_item.id,
        product_variant_id: variant.id,
        sku: variant.sku,
        product_name: order_item.product_name || product.name,
        brand_name: product.brand.name,
        category_name: product.category.name,
        quantity: order_item.quantity,
        price_at_purchase: order_item.price_at_purchase,
        discounted_price: order_item.discounted_price,
        final_price: order_item.final_price,
        subtotal: order_item.subtotal,
        currency: order_item.currency || 'INR',
        fulfillment_status: order_item.fulfillment_status,
        tracking_number: order_item.tracking_number,
        tracking_url: order_item.tracking_url,
        image_url: order_item.product_image_url || 
                   variant.product_images.first&.image_url || 
                   product.product_variants.first&.product_images&.first&.image_url
      }
    end
  end
end

