# frozen_string_literal: true

class AdminActivity < ApplicationRecord
  self.table_name = 'admin_activities'
  
  belongs_to :admin
  
  # Parse activity_changes JSON
  def changes_data
    return {} if activity_changes.blank?
    JSON.parse(activity_changes) rescue {}
  end
  
  def changes_data=(data)
    self.activity_changes = data.to_json
  end
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_resource, ->(type, id) { where(resource_type: type, resource_id: id) }
  
  # Log admin activity
  def self.log_activity(admin, action, resource_type = nil, resource_id = nil, options = {})
    create(
      admin: admin,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id,
      description: options[:description],
      activity_changes: options[:changes]&.to_json || '{}',
      ip_address: options[:ip_address],
      user_agent: options[:user_agent]
    )
  end
end

