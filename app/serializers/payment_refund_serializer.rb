# frozen_string_literal: true

# Serializer for PaymentRefund API responses
class PaymentRefundSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      refund_id: object.refund_id,
      payment_id: object.payment_id,
      order_id: object.order_id,
      amount: format_price(object.amount),
      currency: object.currency,
      reason: object.reason,
      status: object.status,
      gateway_refund_id: object.gateway_refund_id,
      created_at: format_date(object.created_at),
      processed_at: format_date(object.processed_at)
    }
  end

  # Detailed version with all associations
  def detailed
    serialize.merge(
      description: object.description,
      gateway_response: object.gateway_response_data,
      processed_by: serialize_processed_by,
      payment: serialize_payment,
      order: serialize_order
    )
  end

  private

  def serialize_processed_by
    return nil unless object.processed_by

    {
      id: object.processed_by.id,
      name: object.processed_by.full_name
    }
  end

  def serialize_payment
    return nil unless object.payment

    {
      id: object.payment.id,
      payment_id: object.payment.payment_id,
      amount: format_price(object.payment.amount)
    }
  end

  def serialize_order
    return nil unless object.order

    {
      id: object.order.id,
      order_number: object.order.order_number || object.order.id.to_s.rjust(8, '0')
    }
  end
end

