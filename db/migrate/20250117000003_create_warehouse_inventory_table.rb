# frozen_string_literal: true

class CreateWarehouseInventoryTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:warehouse_inventory)
      create_table :warehouse_inventory do |t|
        t.references :warehouse, null: false, foreign_key: true
        t.references :product_variant, null: false, foreign_key: true
        
        # Stock
        t.integer :stock_quantity, default: 0, null: false
        t.integer :reserved_quantity, default: 0
        # Note: SQLite doesn't support generated columns, so available_quantity will be calculated in model
        
        t.timestamps
      end
      
      # Add unique constraint
      add_index :warehouse_inventory, [:warehouse_id, :product_variant_id], unique: true unless index_exists?(:warehouse_inventory, [:warehouse_id, :product_variant_id])
    end
  end
end

