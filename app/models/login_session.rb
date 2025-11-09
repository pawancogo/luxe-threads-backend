# frozen_string_literal: true

class LoginSession < ApplicationRecord
  belongs_to :user, polymorphic: true
  
  # Scopes
  scope :active, -> { where(is_active: true, is_expired: false) }
  scope :expired, -> { where(is_expired: true) }
  scope :successful, -> { where(is_successful: true) }
  scope :failed, -> { where(is_successful: false) }
  scope :recent, -> { order(logged_in_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :by_ip, ->(ip) { where(ip_address: ip) }
  
  # Parse metadata JSON
  def metadata_hash
    return {} if metadata.blank?
    JSON.parse(metadata) rescue {}
  end
  
  def metadata_hash=(hash)
    self.metadata = hash.to_json
  end
  
  # Mark session as logged out
  def logout!
    update(
      logged_out_at: Time.current,
      is_active: false
    )
  end
  
  # Mark session as expired
  def expire!
    update(is_expired: true, is_active: false)
  end
  
  # Update last activity
  def touch_activity!
    update_column(:last_activity_at, Time.current)
  end
  
  # Check if session is still valid
  def valid?
    is_active && !is_expired && logged_out_at.nil?
  end
  
  # Get device summary
  def device_summary
    parts = []
    parts << device_name if device_name.present?
    parts << "#{os_name} #{os_version}".strip if os_name.present?
    parts << "#{browser_name} #{browser_version}".strip if browser_name.present?
    parts.join(' • ') || 'Unknown Device'
  end
  
  # Get location summary
  def location_summary
    parts = []
    parts << city if city.present?
    parts << region if region.present?
    parts << country if country.present?
    parts.join(', ') || ip_address || 'Unknown Location'
  end
end

