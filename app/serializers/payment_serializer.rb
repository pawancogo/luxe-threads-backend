# frozen_string_literal: true

# Serializer for Payment API responses
# Follows vendor-backend ActiveSerializer pattern
class PaymentSerializer < BaseSerializer
  attributes :id, :payment_id, :order_id, :currency, :payment_method, 
             :payment_gateway, :status, :gateway_transaction_id, 
             :gateway_payment_id, :card_last4, :card_brand, :upi_id, :wallet_type, 
             :refund_status

  def attributes(*args)
    result = super
    result[:amount] = format_price(object.amount)
    result[:refund_amount] = format_price(object.refund_amount)
    result[:created_at] = format_date(object.created_at)
    result[:completed_at] = format_date(object.completed_at)
    result
  end
end

