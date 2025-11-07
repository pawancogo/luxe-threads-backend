# frozen_string_literal: true

class CreatePaymentTransactionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_transactions do |t|
      t.string :transaction_id, null: false, limit: 100
      t.references :payment, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      
      # Transaction Details
      t.string :transaction_type, limit: 50, null: false
      # Values: payment, refund, payout, adjustment
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, limit: 10, default: 'INR'
      
      # Status
      t.string :status, limit: 50, null: false
      # Values: pending, processing, completed, failed
      
      # Gateway Response
      t.text :gateway_response # Gateway response (TEXT for SQLite)
      t.text :failure_reason
      
      t.timestamps
    end
    
    add_index :payment_transactions, :transaction_id, unique: true unless index_exists?(:payment_transactions, :transaction_id)
    add_index :payment_transactions, :payment_id unless index_exists?(:payment_transactions, :payment_id)
    add_index :payment_transactions, :order_id unless index_exists?(:payment_transactions, :order_id)
    add_index :payment_transactions, :transaction_type unless index_exists?(:payment_transactions, :transaction_type)
    add_index :payment_transactions, :status unless index_exists?(:payment_transactions, :status)
    add_index :payment_transactions, :created_at unless index_exists?(:payment_transactions, :created_at)
  end
end

