# frozen_string_literal: true

class CreateLoyaltyPointsTransactionsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:loyalty_points_transactions)
      create_table :loyalty_points_transactions do |t|
        t.references :user, null: false, foreign_key: true
        
        # Transaction Details
        t.string :transaction_type, limit: 50, null: false
        # Values: earned, redeemed, expired, adjusted
        t.integer :points, null: false # Positive for earned, negative for redeemed
        t.integer :balance_after, null: false
        
        # Reference
        t.string :reference_type, limit: 50 # order, referral, promotion, adjustment
        t.integer :reference_id
        
        # Details
        t.text :description
        t.date :expiry_date # For earned points
        
        t.timestamps
      end
      
      add_index :loyalty_points_transactions, :transaction_type unless index_exists?(:loyalty_points_transactions, :transaction_type)
      add_index :loyalty_points_transactions, [:reference_type, :reference_id] unless index_exists?(:loyalty_points_transactions, [:reference_type, :reference_id])
      add_index :loyalty_points_transactions, :created_at unless index_exists?(:loyalty_points_transactions, :created_at)
    end
  end
end

