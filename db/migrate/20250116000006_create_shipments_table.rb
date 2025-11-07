# frozen_string_literal: true

class CreateShipmentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :shipments do |t|
      t.string :shipment_id, null: false, limit: 100
      t.references :order, null: false, foreign_key: true
      t.references :order_item, null: true, foreign_key: true # For split shipments
      
      # Shipping Details
      t.references :shipping_method, null: true, foreign_key: true
      t.string :shipping_provider, limit: 100
      t.string :tracking_number, limit: 255
      t.string :tracking_url, limit: 500
      
      # Addresses
      t.text :from_address, null: false # Warehouse address (TEXT for SQLite)
      t.text :to_address, null: false # Delivery address (TEXT for SQLite)
      
      # Status
      t.string :status, limit: 50, null: false, default: 'pending'
      # Values: pending, label_created, picked_up, in_transit, 
      #         out_for_delivery, delivered, failed, returned
      t.timestamp :status_updated_at
      
      # Dates
      t.timestamp :shipped_at
      t.date :estimated_delivery_date
      t.date :actual_delivery_date
      
      # Delivery Details
      t.string :delivered_to, limit: 255 # Person who received
      t.text :delivery_notes
      t.string :delivery_proof_image_url, limit: 500
      
      # Weight & Dimensions
      t.decimal :weight_kg, precision: 8, scale: 3
      t.decimal :length_cm, precision: 8, scale: 2
      t.decimal :width_cm, precision: 8, scale: 2
      t.decimal :height_cm, precision: 8, scale: 2
      
      # Charges
      t.decimal :shipping_charge, precision: 10, scale: 2
      t.decimal :cod_charge, precision: 10, scale: 2
      
      t.timestamps
    end
    
    add_index :shipments, :shipment_id, unique: true unless index_exists?(:shipments, :shipment_id)
    add_index :shipments, :order_id unless index_exists?(:shipments, :order_id)
    add_index :shipments, :tracking_number unless index_exists?(:shipments, :tracking_number)
    add_index :shipments, :status unless index_exists?(:shipments, :status)
    add_index :shipments, :shipping_provider unless index_exists?(:shipments, :shipping_provider)
  end
end

