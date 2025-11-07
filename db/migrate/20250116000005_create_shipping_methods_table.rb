# frozen_string_literal: true

class CreateShippingMethodsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :shipping_methods do |t|
      t.string :name, null: false, limit: 255
      t.string :code, null: false, limit: 50
      t.text :description
      
      # Shipping Provider
      t.string :provider, limit: 100 # delhivery, fedex, bluedart, etc.
      t.string :provider_code, limit: 50
      
      # Pricing
      t.decimal :base_charge, precision: 10, scale: 2, default: 0
      t.decimal :per_kg_charge, precision: 10, scale: 2, default: 0
      t.decimal :free_shipping_above, precision: 10, scale: 2
      
      # Delivery Time
      t.integer :estimated_days_min
      t.integer :estimated_days_max
      
      # Coverage
      t.text :available_pincodes # Array of pincodes (TEXT for SQLite)
      t.text :excluded_pincodes # Array of excluded pincodes (TEXT for SQLite)
      t.text :available_zones, default: '{}' # Zone-based availability (TEXT for SQLite)
      
      # Status
      t.boolean :is_active, default: true
      t.boolean :is_cod_available, default: false
      
      t.timestamps
    end
    
    add_index :shipping_methods, :code, unique: true unless index_exists?(:shipping_methods, :code)
    add_index :shipping_methods, :is_active unless index_exists?(:shipping_methods, :is_active)
  end
end

