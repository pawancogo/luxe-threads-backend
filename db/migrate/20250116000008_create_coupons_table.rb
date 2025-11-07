# frozen_string_literal: true

class CreateCouponsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false, limit: 50
      
      # Coupon Details
      t.string :name, null: false, limit: 255
      t.text :description
      t.string :coupon_type, limit: 50, null: false
      # Values: percentage, fixed_amount, free_shipping, buy_one_get_one
      
      # Discount
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      # For percentage: 10 means 10%
      # For fixed: 100 means ₹100
      t.decimal :max_discount_amount, precision: 10, scale: 2 # For percentage coupons
      t.decimal :min_order_amount, precision: 10, scale: 2, default: 0
      
      # Validity
      t.timestamp :valid_from, null: false
      t.timestamp :valid_until, null: false
      t.boolean :is_active, default: true
      
      # Usage Limits
      t.integer :max_uses # Total uses allowed
      t.integer :max_uses_per_user, default: 1
      t.integer :current_uses, default: 0
      
      # Applicability
      t.text :applicable_categories # Category IDs (TEXT for SQLite)
      t.text :applicable_products # Product IDs (TEXT for SQLite)
      t.text :applicable_brands # Brand IDs (TEXT for SQLite)
      t.text :applicable_suppliers # Supplier IDs (TEXT for SQLite)
      t.text :exclude_categories # Exclude category IDs (TEXT for SQLite)
      t.text :exclude_products # Exclude product IDs (TEXT for SQLite)
      
      # User Restrictions
      t.text :applicable_user_ids # User IDs (TEXT for SQLite)
      t.text :exclude_user_ids # Exclude user IDs (TEXT for SQLite)
      t.boolean :new_users_only, default: false
      t.boolean :first_order_only, default: false
      
      # Admin
      t.references :created_by, null: true, foreign_key: { to_table: :admins }
      
      t.timestamps
    end
    
    add_index :coupons, :code, unique: true unless index_exists?(:coupons, :code)
    add_index :coupons, :is_active unless index_exists?(:coupons, :is_active)
    add_index :coupons, [:valid_from, :valid_until] unless index_exists?(:coupons, [:valid_from, :valid_until])
  end
end

