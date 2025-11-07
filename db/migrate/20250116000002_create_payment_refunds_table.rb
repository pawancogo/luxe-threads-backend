# frozen_string_literal: true

class CreatePaymentRefundsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_refunds do |t|
      t.string :refund_id, null: false, limit: 100
      t.references :payment, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :order_item, null: true, foreign_key: true # If partial refund
      
      # Refund Details
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, limit: 10, default: 'INR'
      t.string :reason, limit: 255, null: false
      t.text :description
      
      # Status
      t.string :status, limit: 50, null: false, default: 'pending'
      # Values: pending, processing, completed, failed, cancelled
      
      # Payment Gateway
      t.string :gateway_refund_id, limit: 255
      t.text :gateway_response # Gateway response (TEXT for SQLite)
      
      # Processing
      t.references :processed_by, null: true, foreign_key: { to_table: :users } # Admin who processed
      t.timestamp :processed_at
      
      t.timestamps
    end
    
    add_index :payment_refunds, :refund_id, unique: true unless index_exists?(:payment_refunds, :refund_id)
    add_index :payment_refunds, :payment_id unless index_exists?(:payment_refunds, :payment_id)
    add_index :payment_refunds, :order_id unless index_exists?(:payment_refunds, :order_id)
    add_index :payment_refunds, :status unless index_exists?(:payment_refunds, :status)
  end
end

