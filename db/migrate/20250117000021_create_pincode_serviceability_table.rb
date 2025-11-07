# frozen_string_literal: true

class CreatePincodeServiceabilityTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:pincode_serviceability)
      create_table :pincode_serviceability do |t|
        t.string :pincode, limit: 20, null: false
        
        # Serviceability
        t.boolean :is_serviceable, default: true
        t.boolean :is_cod_available, default: false
        
        # Location
        t.string :city, limit: 100
        t.string :state, limit: 100
        t.string :district, limit: 100
        t.string :zone, limit: 50
        
        # Delivery Time
        t.integer :standard_delivery_days
        t.integer :express_delivery_days
        
        t.timestamps
      end
      
      add_index :pincode_serviceability, :pincode, unique: true
      add_index :pincode_serviceability, :city
      add_index :pincode_serviceability, :state
    end
  end
end

