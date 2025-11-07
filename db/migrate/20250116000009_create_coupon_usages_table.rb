# frozen_string_literal: true

class CreateCouponUsagesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :coupon_usages do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      
      # Usage Details
      t.decimal :discount_amount, precision: 10, scale: 2, null: false
      t.decimal :order_amount, precision: 10, scale: 2, null: false
      
      t.timestamps
    end
    
    add_index :coupon_usages, [:coupon_id, :user_id] unless index_exists?(:coupon_usages, [:coupon_id, :user_id])
    add_index :coupon_usages, :order_id unless index_exists?(:coupon_usages, :order_id)
    add_index :coupon_usages, :created_at unless index_exists?(:coupon_usages, :created_at)
  end
end

