# frozen_string_literal: true

class CreateWarehousesTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:warehouses)
      create_table :warehouses do |t|
        t.references :supplier_profile, null: false, foreign_key: true
        
        # Warehouse Details
        t.string :name, limit: 255, null: false
        t.string :code, limit: 50, null: false
        t.text :address, null: false
        t.string :city, limit: 100
        t.string :state, limit: 100
        t.string :pincode, limit: 20
        t.string :country, limit: 100, default: 'India'
        
        # Contact
        t.string :contact_person, limit: 255
        t.string :contact_phone, limit: 20
        t.string :contact_email, limit: 255
        
        # Status
        t.boolean :is_active, default: true
        t.boolean :is_primary, default: false
        
        t.timestamps
      end
      
      # Add unique constraint and indexes
      add_index :warehouses, [:supplier_profile_id, :code], unique: true unless index_exists?(:warehouses, [:supplier_profile_id, :code])
      add_index :warehouses, :is_active unless index_exists?(:warehouses, :is_active)
    end
  end
end

