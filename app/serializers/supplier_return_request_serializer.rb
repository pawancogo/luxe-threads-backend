# frozen_string_literal: true

# Serializer for supplier return request responses
class SupplierReturnRequestSerializer < BaseSerializer
  attributes :id, :return_id, :order_id, :order_number, :customer_name,
             :customer_email, :status, :resolution_type, :refund_status,
             :created_at, :status_updated_at, :items_count, :total_quantity,
             :items, :order, :status_history, :pickup_address,
             :pickup_scheduled_at, :refund_amount, :refund_id

  def return_id
    object.return_id
  end

  def order_id
    object.order_id
  end

  def order_number
    object.order.order_number || object.order.id.to_s.rjust(8, '0')
  end

  def customer_name
    object.user.full_name
  end

  def customer_email
    object.user.email
  end

  def resolution_type
    object.resolution_type
  end

  def refund_status
    object.refund_status
  end

  def status_updated_at
    object.status_updated_at&.iso8601
  end

  def items_count
    object.return_items.count
  end

  def total_quantity
    object.return_items.sum(:quantity)
  end

  def items
    object.return_items.map do |return_item|
      order_item = return_item.order_item
      variant = order_item.product_variant
      product = variant.product
      
      {
        return_item_id: return_item.id,
        order_item_id: order_item.id,
        product_name: order_item.product_name || product.name,
        product_variant_id: variant.id,
        sku: variant.sku,
        quantity: return_item.quantity,
        reason: return_item.reason,
        price_at_purchase: order_item.price_at_purchase,
        subtotal: order_item.price_at_purchase * return_item.quantity,
        image_url: order_item.product_image_url || 
                   variant.product_images.first&.image_url || 
                   product.product_variants.first&.product_images&.first&.image_url
      }
    end
  end

  def order
    {
      id: object.order.id,
      order_number: object.order.order_number || object.order.id.to_s.rjust(8, '0'),
      total_amount: object.order.total_amount,
      currency: object.order.currency || 'INR',
      order_date: object.order.created_at.iso8601
    }
  end

  def status_history
    object.status_history_data
  end

  def pickup_address
    return nil unless object.pickup_address
    
    address = object.pickup_address
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

  def pickup_scheduled_at
    object.pickup_scheduled_at&.iso8601
  end

  def refund_amount
    object.refund_amount
  end

  def refund_id
    object.refund_id
  end
end

