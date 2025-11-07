# frozen_string_literal: true

class CreateInventoryTransactionsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:inventory_transactions)
      create_table :inventory_transactions do |t|
        t.string :transaction_id, limit: 100, null: false
        
        # Product Information
        t.references :product_variant, null: false, foreign_key: true
        t.references :supplier_profile, null: false, foreign_key: true
        
        # Transaction Details
        t.string :transaction_type, limit: 50, null: false
        # Values: purchase, sale, return, adjustment, transfer, damage, expiry
        t.integer :quantity, null: false # Positive for additions, negative for deductions
        t.integer :balance_after, null: false # Stock after this transaction
        
        # Reference
        t.string :reference_type, limit: 50 # order, return, adjustment, transfer
        t.integer :reference_id
        
        # Details
        t.text :reason
        t.text :notes
        
        # User
        t.references :performed_by, foreign_key: { to_table: :users }
        t.string :performed_by_type, limit: 50 # user, supplier, admin, system
        
        t.timestamps
      end
      
      # Add unique constraint and indexes
      add_index :inventory_transactions, :transaction_id, unique: true unless index_exists?(:inventory_transactions, :transaction_id)
      add_index :inventory_transactions, :transaction_type unless index_exists?(:inventory_transactions, :transaction_type)
      add_index :inventory_transactions, [:reference_type, :reference_id] unless index_exists?(:inventory_transactions, [:reference_type, :reference_id])
      add_index :inventory_transactions, :created_at unless index_exists?(:inventory_transactions, :created_at)
    end
  end
end

