# frozen_string_literal: true

# Serializer for ShipmentTrackingEvent API responses
class ShipmentTrackingEventSerializer < BaseSerializer
  attributes :id, :event_type, :event_description, :location, :city, :state,
             :pincode, :event_time, :source, :created_at
end

