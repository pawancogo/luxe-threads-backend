# frozen_string_literal: true

class CreateProductViewsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:product_views)
      create_table :product_views do |t|
        t.references :product, null: false, foreign_key: true
        t.references :user, foreign_key: true # NULL for anonymous
        t.references :product_variant, foreign_key: true
        
        # Session
        t.string :session_id, limit: 255
        t.string :ip_address, limit: 50
        t.text :user_agent
        
        # Source
        t.string :referrer_url, limit: 500
        t.string :source, limit: 50 # search, category, brand, direct, recommendation
        
        # Timestamps
        t.timestamp :viewed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
        
        t.timestamps
      end
      
      add_index :product_views, :viewed_at unless index_exists?(:product_views, :viewed_at)
      add_index :product_views, :session_id unless index_exists?(:product_views, :session_id)
    end
  end
end

