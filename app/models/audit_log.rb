# frozen_string_literal: true

class AuditLog < ApplicationRecord
  self.table_name = 'audit_logs'
  
  belongs_to :user, optional: true
  
  # Actions
  # Using different enum keys to avoid conflict with Active Record's 'create' method
  # The database values remain 'create', 'update', 'delete'
  enum :action, {
    created: 'create',
    updated: 'update',
    deleted: 'delete'
  }
  
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true
  validates :action, presence: true
  
  # Parse changes JSON
  def changes_data
    return {} if changes.blank?
    JSON.parse(changes) rescue {}
  end
  
  def changes_data=(data)
    self.changes = data.to_json
  end
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_auditable, ->(type, id) { where(auditable_type: type, auditable_id: id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  
  # Get auditable object
  def auditable
    return nil unless auditable_type.present? && auditable_id.present?
    auditable_type.constantize.find_by(id: auditable_id)
  rescue NameError
    nil
  end
end

