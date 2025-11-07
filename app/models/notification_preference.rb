# frozen_string_literal: true

class NotificationPreference < ApplicationRecord
  self.table_name = 'notification_preferences'
  
  belongs_to :user
  
  validates :user_id, uniqueness: true
  
  # Parse preferences JSON
  def preferences_hash
    return default_preferences if preferences.blank?
    JSON.parse(preferences) rescue default_preferences
  end
  
  def preferences_hash=(hash)
    self.preferences = hash.to_json
  end
  
  # Get preference value
  def get_preference(channel, type)
    prefs = preferences_hash
    prefs.dig(channel.to_s, type.to_s) || false
  end
  
  # Set preference value
  def set_preference(channel, type, value)
    prefs = preferences_hash
    prefs[channel.to_s] ||= {}
    prefs[channel.to_s][type.to_s] = value
    self.preferences_hash = prefs
  end
  
  private
  
  def default_preferences
    {
      'email' => {
        'order_updates' => true,
        'promotions' => true,
        'reviews' => true,
        'system' => true
      },
      'sms' => {
        'order_updates' => true,
        'promotions' => false,
        'reviews' => false,
        'system' => false
      },
      'push' => {
        'order_updates' => true,
        'promotions' => true,
        'reviews' => true,
        'system' => true
      }
    }
  end
end

