# frozen_string_literal: true

class ShipmentTrackingEvent < ApplicationRecord
  belongs_to :shipment
  
  # Event types
  enum event_type: {
    label_created: 'label_created',
    picked_up: 'picked_up',
    in_transit: 'in_transit',
    out_for_delivery: 'out_for_delivery',
    delivered: 'delivered',
    failed: 'failed',
    returned: 'returned'
  }
  
  validates :event_type, presence: true
  validates :event_time, presence: true
  
  scope :chronological, -> { order(:event_time) }
  scope :recent, -> { order(event_time: :desc) }
end


