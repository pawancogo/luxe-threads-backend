# frozen_string_literal: true

# Serializer for Shipment API responses
class ShipmentSerializer < BaseSerializer
  attributes :id, :shipment_id, :order_id, :order_item_id, :shipping_provider,
             :tracking_number, :tracking_url, :status, :shipped_at,
             :estimated_delivery_date, :actual_delivery_date, :created_at,
             :from_address, :to_address, :weight_kg, :shipping_charge,
             :cod_charge, :tracking_events

  def from_address
    object.from_address_data
  end

  def to_address
    object.to_address_data
  end

  def weight_kg
    object.weight_kg&.to_f
  end

  def shipping_charge
    object.shipping_charge&.to_f
  end

  def cod_charge
    object.cod_charge&.to_f
  end

  def tracking_events
    object.shipment_tracking_events.order(:event_time).map do |event|
      {
        id: event.id,
        event_type: event.event_type,
        event_description: event.event_description,
        location: event.location,
        city: event.city,
        state: event.state,
        pincode: event.pincode,
        event_time: event.event_time,
        source: event.source,
        created_at: event.created_at
      }
    end
  end
end

