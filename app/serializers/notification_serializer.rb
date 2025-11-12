# frozen_string_literal: true

# Serializer for Notification API responses
class NotificationSerializer < BaseSerializer
  attributes :id, :title, :message, :notification_type, :data, :is_read,
             :read_at, :created_at

  def data
    object.data_hash
  end

  def is_read
    object.is_read
  end

  def read_at
    object.read_at
  end
end

