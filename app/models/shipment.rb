# frozen_string_literal: true

class Shipment < ApplicationRecord
  belongs_to :order
  belongs_to :order_item, optional: true
  belongs_to :shipping_method, optional: true
  
  has_many :shipment_tracking_events, dependent: :destroy
  
  # Status
  enum status: {
    pending: 'pending',
    label_created: 'label_created',
    picked_up: 'picked_up',
    in_transit: 'in_transit',
    out_for_delivery: 'out_for_delivery',
    delivered: 'delivered',
    failed: 'failed',
    returned: 'returned'
  }
  
  validates :shipment_id, presence: true, uniqueness: true
  validates :from_address, presence: true
  validates :to_address, presence: true
  
  # Generate unique shipment_id
  before_validation :generate_shipment_id, on: :create
  
  # Update status_updated_at when status changes
  before_save :update_status_timestamp, if: :status_changed?
  
  # Parse from_address JSON
  def from_address_data
    return {} if from_address.blank?
    JSON.parse(from_address) rescue {}
  end
  
  def from_address_data=(data)
    self.from_address = data.to_json
  end
  
  # Parse to_address JSON
  def to_address_data
    return {} if to_address.blank?
    JSON.parse(to_address) rescue {}
  end
  
  def to_address_data=(data)
    self.to_address = data.to_json
  end
  
  private
  
  def generate_shipment_id
    return if shipment_id.present?
    self.shipment_id = "SHIP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
  
  def update_status_timestamp
    self.status_updated_at = Time.current
  end
end


