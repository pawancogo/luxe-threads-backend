# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  
  # Notification types
  enum :notification_type, {
    order_update: 'order_update',
    payment: 'payment',
    promotion: 'promotion',
    review: 'review',
    system: 'system',
    shipping: 'shipping'
  }
  
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true
  
  # Parse data JSON
  def data_hash
    return {} if data.blank?
    JSON.parse(data) rescue {}
  end
  
  def data_hash=(hash)
    self.data = hash.to_json
  end
  
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  
  # Mark as read
  def mark_as_read!
    update(is_read: true, read_at: Time.current)
  end
end

