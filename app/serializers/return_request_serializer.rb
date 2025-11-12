# frozen_string_literal: true

# Serializer for ReturnRequest API responses
class ReturnRequestSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      return_id: object.return_id,
      order_id: object.order_id,
      status: object.status,
      return_type: object.return_type,
      pickup_scheduled_at: format_date(object.pickup_scheduled_at),
      created_at: format_date(object.created_at),
      updated_at: format_date(object.updated_at)
    }
  end

  # Detailed version with all associations
  def detailed
    serialize.merge(
      order: serialize_order,
      return_items: serialize_return_items,
      status_history: object.status_history_data || []
    )
  end

  private

  def serialize_order
    return nil unless object.order

    {
      id: object.order.id,
      order_number: object.order.order_number,
      total_amount: format_price(object.order.total_amount),
      status: object.order.status
    }
  end

  def serialize_return_items
    return [] unless object.return_items.any?

    object.return_items.map do |item|
      {
        id: item.id,
        order_item_id: item.order_item_id,
        quantity: item.quantity,
        reason: item.reason,
        status: item.status,
        media: item.return_media.map do |media|
          {
            id: media.id,
            media_url: media.media_url,
            media_type: media.media_type
          }
        end
      }
    end
  end
end

