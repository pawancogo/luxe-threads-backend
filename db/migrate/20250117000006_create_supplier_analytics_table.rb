# frozen_string_literal: true

class CreateSupplierAnalyticsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:supplier_analytics)
      create_table :supplier_analytics do |t|
        t.references :supplier_profile, null: false, foreign_key: true
        
        # Date
        t.date :date, null: false
        
        # Sales Metrics
        t.integer :total_orders, default: 0
        t.decimal :total_revenue, precision: 12, scale: 2, default: 0
        t.integer :total_items_sold, default: 0
        
        # Product Metrics
        t.integer :products_viewed, default: 0
        t.integer :products_added_to_cart, default: 0
        t.decimal :conversion_rate, precision: 5, scale: 2, default: 0
        
        # Customer Metrics
        t.integer :new_customers, default: 0
        t.integer :returning_customers, default: 0
        
        # Ratings
        t.decimal :average_rating, precision: 3, scale: 2, default: 0
        t.integer :new_reviews_count, default: 0
        
        t.timestamps
      end
      
      # Add unique constraint and indexes
      add_index :supplier_analytics, [:supplier_profile_id, :date], unique: true unless index_exists?(:supplier_analytics, [:supplier_profile_id, :date])
      add_index :supplier_analytics, :date unless index_exists?(:supplier_analytics, :date)
    end
  end
end

