# frozen_string_literal: true

class CreateShipmentTrackingEventsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :shipment_tracking_events do |t|
      t.references :shipment, null: false, foreign_key: true
      
      # Event Details
      t.string :event_type, limit: 50, null: false
      # Values: label_created, picked_up, in_transit, out_for_delivery, 
      #         delivered, failed, returned
      t.text :event_description
      t.string :location, limit: 255
      t.string :city, limit: 100
      t.string :state, limit: 100
      t.string :pincode, limit: 20
      
      # Timestamps
      t.timestamp :event_time, null: false
      
      # Source
      t.string :source, limit: 50, default: 'provider' # provider, manual, system
      
      t.timestamps
    end
    
    add_index :shipment_tracking_events, :shipment_id unless index_exists?(:shipment_tracking_events, :shipment_id)
    add_index :shipment_tracking_events, :event_time unless index_exists?(:shipment_tracking_events, :event_time)
  end
end

