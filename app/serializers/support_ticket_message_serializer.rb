# frozen_string_literal: true

# Serializer for SupportTicketMessage API responses
class SupportTicketMessageSerializer < BaseSerializer
  attributes :id, :message, :sender_type, :sender_name, :attachments,
             :is_internal, :is_read, :created_at

  def sender_name
    object.sender&.full_name || 'Support'
  end

  def attachments
    object.attachments_list
  end

  def is_internal
    object.is_internal
  end

  def is_read
    object.is_read
  end
end

