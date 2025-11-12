# frozen_string_literal: true

# Serializer for SupportTicket API responses
class SupportTicketSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      ticket_id: object.ticket_id,
      subject: object.subject,
      category: object.category,
      status: object.status,
      priority: object.priority,
      created_at: format_date(object.created_at),
      assigned_to: object.assigned_to&.full_name,
      message_count: object.support_ticket_messages.count
    }
  end

  # Detailed version with all fields and messages
  def detailed
    serialize.merge(
      description: object.description,
      resolution: object.resolution,
      resolved_at: format_date(object.resolved_at),
      resolved_by: object.resolved_by&.full_name,
      assigned_at: format_date(object.assigned_at),
      closed_at: format_date(object.closed_at),
      order_id: object.order_id,
      product_id: object.product_id,
      messages: serialize_messages
    )
  end

  private

  def serialize_messages
    return [] unless object.support_ticket_messages.any?

    object.support_ticket_messages.visible_to_user.map do |message|
      {
        id: message.id,
        message: message.message,
        sender_type: message.sender_type,
        sender_name: message.sender&.full_name || 'Support',
        attachments: message.attachments_list || [],
        is_read: format_boolean(message.is_read),
        created_at: format_date(message.created_at)
      }
    end
  end
end


