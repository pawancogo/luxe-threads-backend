# frozen_string_literal: true

class SupportTicketMessage < ApplicationRecord
  belongs_to :support_ticket
  
  validates :message, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :sender_type, presence: true
  validates :sender_id, presence: true
  
  # Sanitize user input to prevent XSS
  before_save :sanitize_message
  
  def sanitize_message
    self.message = ActionController::Base.helpers.sanitize(message, tags: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li'], attributes: [])
  end
  
  # Parse attachments JSON
  def attachments_list
    return [] if attachments.blank?
    JSON.parse(attachments) rescue []
  end
  
  def attachments_list=(list)
    self.attachments = list.to_json
  end
  
  scope :recent, -> { order(created_at: :asc) }
  scope :visible_to_user, -> { where(is_internal: false) }
  scope :internal, -> { where(is_internal: true) }
  
  # Mark as read
  def mark_as_read!
    update(is_read: true, read_at: Time.current)
  end
  
  # Get sender
  def sender
    return nil unless sender_type.present? && sender_id.present?
    
    case sender_type
    when 'user'
      User.find_by(id: sender_id)
    when 'admin'
      Admin.find_by(id: sender_id)
    else
      nil
    end
  end
end

