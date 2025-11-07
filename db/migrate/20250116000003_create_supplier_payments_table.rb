# frozen_string_literal: true

class CreateSupplierPaymentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_payments do |t|
      t.string :payment_id, null: false, limit: 100
      t.references :supplier_profile, null: false, foreign_key: true
      
      # Payment Details
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, limit: 10, default: 'INR'
      t.decimal :commission_deducted, precision: 10, scale: 2, default: 0
      t.decimal :net_amount, precision: 10, scale: 2, null: false # amount - commission
      
      # Payment Method
      t.string :payment_method, limit: 50, null: false # bank_transfer, upi, neft, rtgs
      t.string :bank_account_number, limit: 50
      t.string :bank_ifsc_code, limit: 20
      t.string :transaction_reference, limit: 255
      
      # Status
      t.string :status, limit: 50, null: false, default: 'pending'
      # Values: pending, processing, completed, failed, cancelled
      t.text :failure_reason
      
      # Period
      t.date :period_start_date, null: false
      t.date :period_end_date, null: false
      t.integer :order_items_count, default: 0
      
      # Processing
      t.references :processed_by, null: true, foreign_key: { to_table: :admins }
      t.timestamp :processed_at
      
      t.timestamps
    end
    
    add_index :supplier_payments, :payment_id, unique: true unless index_exists?(:supplier_payments, :payment_id)
    add_index :supplier_payments, :supplier_profile_id unless index_exists?(:supplier_payments, :supplier_profile_id)
    add_index :supplier_payments, :status unless index_exists?(:supplier_payments, :status)
    add_index :supplier_payments, [:period_start_date, :period_end_date] unless index_exists?(:supplier_payments, [:period_start_date, :period_end_date])
  end
end

