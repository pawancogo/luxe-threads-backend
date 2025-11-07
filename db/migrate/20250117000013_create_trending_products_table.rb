# frozen_string_literal: true

class CreateTrendingProductsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:trending_products)
      create_table :trending_products do |t|
        t.references :product, null: false, foreign_key: true
        
        # Metrics (cached)
        t.integer :views_24h, default: 0
        t.integer :orders_24h, default: 0
        t.decimal :revenue_24h, precision: 12, scale: 2, default: 0
        t.decimal :trend_score, precision: 10, scale: 2, default: 0
        
        # Category Trending
        t.references :category, foreign_key: true
        t.integer :rank_in_category
        
        # Timestamps
        t.timestamp :calculated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
        
        t.timestamps
      end
      
      # Add unique constraint and indexes
      add_index :trending_products, [:product_id, :calculated_at], unique: true unless index_exists?(:trending_products, [:product_id, :calculated_at])
      add_index :trending_products, :trend_score unless index_exists?(:trending_products, :trend_score)
      add_index :trending_products, :calculated_at unless index_exists?(:trending_products, :calculated_at)
    end
  end
end

