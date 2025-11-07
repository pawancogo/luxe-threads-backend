# frozen_string_literal: true

class CreatePaymentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.string :payment_id, null: false, limit: 100
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      # Payment Details
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, limit: 10, default: 'INR'
      t.string :payment_method, limit: 50, null: false
      # Values: cod, credit_card, debit_card, upi, wallet, netbanking, emi
      
      # Payment Gateway
      t.string :payment_gateway, limit: 50 # razorpay, stripe, payu, paytm
      t.string :gateway_transaction_id, limit: 255
      t.string :gateway_payment_id, limit: 255
      t.text :gateway_response # Full response from gateway (TEXT for SQLite)
      
      # Status
      t.string :status, limit: 50, null: false, default: 'pending'
      # Values: pending, processing, completed, failed, refunded, partially_refunded
      t.text :failure_reason
      
      # Payment Information (for card/UPI)
      t.string :card_last4, limit: 4
      t.string :card_brand, limit: 50 # visa, mastercard, amex
      t.string :upi_id, limit: 255
      t.string :wallet_type, limit: 50 # paytm, phonepe, amazon_pay
      
      # Refund Information
      t.decimal :refund_amount, precision: 10, scale: 2, default: 0
      t.string :refund_status, limit: 50 # pending, processing, completed, failed
      t.string :refund_id, limit: 255
      t.timestamp :refunded_at
      
      # Timestamps
      t.timestamp :completed_at
      
      t.timestamps
    end
    
    add_index :payments, :payment_id, unique: true unless index_exists?(:payments, :payment_id)
    add_index :payments, :order_id unless index_exists?(:payments, :order_id)
    add_index :payments, :user_id unless index_exists?(:payments, :user_id)
    add_index :payments, :status unless index_exists?(:payments, :status)
    add_index :payments, :gateway_transaction_id unless index_exists?(:payments, :gateway_transaction_id)
    add_index :payments, :created_at unless index_exists?(:payments, :created_at)
  end
end

