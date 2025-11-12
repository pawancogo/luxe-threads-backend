# frozen_string_literal: true

# Serializer for Order API responses
# Follows vendor-backend ActiveSerializer pattern
# Supports passing options/params and nested serializers
class OrderSerializer < BaseSerializer
  attributes :id, :status, :payment_status, :currency, :shipping_method, 
             :tracking_number, :tracking_url

  # Nested serializers - options are automatically passed through to nested serializers
  # All options passed to OrderSerializer are available in nested serializers via options method
  has_one :shipping_address, serializer: AddressSerializer
  has_one :billing_address, serializer: AddressSerializer
  # Pass specific options to nested serializer using serializer_options:
  # Example: has_many :order_items, serializer: OrderItemSerializer, serializer_options: { include_product_details: true }
  has_many :order_items, serializer: OrderItemSerializer
  # Conditional associations - only include if loaded
  has_one :user, serializer: UserSerializer, if: :user_loaded?

  def attributes(*args)
    result = super
    result[:order_number] = order_number
    result[:total_amount] = format_price(object.total_amount)
    result[:tax_amount] = format_price(object.tax_amount)
    result[:coupon_discount] = format_price(object.coupon_discount)
    result[:estimated_delivery_date] = format_date(object.estimated_delivery_date)
    result[:actual_delivery_date] = format_date(object.actual_delivery_date)
    result[:status_history] = object.status_history_array
    result[:created_at] = format_date(object.created_at)
    result[:currency] ||= 'INR'
    
    # Access options/params passed to serializer
    result[:include_payments] = serialize_payments if options[:include_payments]
    result[:include_refunds] = serialize_refunds if options[:include_refunds]
    
    # Options are automatically passed to nested serializers (has_one, has_many, belongs_to)
    # Nested serializers can access via options method
    # Example: OrderItemSerializer can access options[:include_product_details]
    # You can also pass association-specific options using serializer_options: in the association declaration
    result
  end

  # Helper to check if association is loaded - modern pattern
  def user_loaded?
    return true if options[:include_user]
    return false unless object.respond_to?(:association)
    object.association(:user).loaded?
  end

  private

  def serialize_payments
    return [] unless object.respond_to?(:payments)
    # Pass options through to nested serializer
    object.payments.map { |payment| PaymentSerializer.new(payment, options).as_json }
  end

  def serialize_refunds
    return [] unless object.respond_to?(:payment_refunds)
    # Pass options through to nested serializer
    object.payment_refunds.map { |refund| PaymentRefundSerializer.new(refund, options).as_json }
  end

  # Summary version for list views
  def summary
    {
      id: object.id,
      order_number: order_number,
      status: object.status,
      payment_status: object.payment_status,
      total_amount: format_price(object.total_amount),
      currency: object.currency || 'INR',
      shipping_method: object.shipping_method,
      tracking_number: object.tracking_number,
      estimated_delivery_date: format_date(object.estimated_delivery_date),
      created_at: format_date(object.created_at),
      item_count: object.order_items.sum(:quantity),
      items: object.order_items.limit(3).map { |item| serialize_item_summary(item) }
    }
  end

  private

  def order_number
    object.order_number || object.id.to_s.rjust(8, '0')
  end

  def serialize_item_summary(item)
    {
      id: item.id,
      product_name: item.product_name,
      product_image_url: item.product_image_url,
      quantity: item.quantity,
      final_price: format_price(item.final_price)
    }
  end
end

