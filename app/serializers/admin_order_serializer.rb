# frozen_string_literal: true

# Serializer for admin order API responses
class AdminOrderSerializer < BaseSerializer
  attributes :id, :order_number, :status, :payment_status, :total_amount,
             :currency, :items_count, :created_at, :updated_at, :user,
             :shipping_address, :billing_address, :items, :payments,
             :refunds, :status_history, :internal_notes, :customer_notes,
             :tracking_number, :tracking_url, :cancellation_reason,
             :cancelled_at, :cancelled_by

  def order_number
    object.order_number
  end

  def total_amount
    object.total_amount.to_f
  end

  def items_count
    object.order_items.count
  end

  def user
    {
      id: object.user.id,
      name: object.user.full_name,
      email: object.user.email
    }
  end

  def shipping_address
    return nil unless object.shipping_address
    
    address = object.shipping_address
    {
      id: address.id,
      street: address.street,
      city: address.city,
      state: address.state,
      zip_code: address.zip_code,
      country: address.country,
      phone_number: address.phone_number
    }
  end

  def billing_address
    return nil unless object.billing_address
    
    address = object.billing_address
    {
      id: address.id,
      street: address.street,
      city: address.city,
      state: address.state,
      zip_code: address.zip_code,
      country: address.country,
      phone_number: address.phone_number
    }
  end

  def items
    object.order_items.map do |item|
      {
        id: item.id,
        product_name: item.product_name || item.product_variant&.product&.name,
        variant_sku: item.variant_sku || item.product_variant&.sku,
        quantity: item.quantity,
        price: item.price.to_f,
        total: (item.price * item.quantity).to_f
      }
    end
  end

  def payments
    object.payments.map do |payment|
      {
        id: payment.id,
        amount: payment.amount.to_f,
        status: payment.status,
        method: payment.payment_method,
        created_at: payment.created_at
      }
    end
  end

  def refunds
    object.payment_refunds.map do |refund|
      {
        id: refund.id,
        amount: refund.amount.to_f,
        status: refund.status,
        reason: refund.reason,
        created_at: refund.created_at
      }
    end
  end

  def status_history
    object.status_history_array
  end
end

