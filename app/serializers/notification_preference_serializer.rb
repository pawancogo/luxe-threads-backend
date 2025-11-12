# frozen_string_literal: true

# Serializer for Notification Preference API responses
class NotificationPreferenceSerializer < BaseSerializer
  attributes :preferences, :created_at, :updated_at

  def preferences
    object.preferences_hash
  end
end

