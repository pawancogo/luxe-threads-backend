# frozen_string_literal: true

class CreatePromotionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :promotions do |t|
      t.string :name, null: false, limit: 255
      t.text :description
      
      # Promotion Type
      t.string :promotion_type, limit: 50, null: false
      # Values: flash_sale, buy_x_get_y, bundle_deal, seasonal_sale
      
      # Discount
      t.decimal :discount_percentage, precision: 5, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2
      
      # Validity
      t.timestamp :start_date, null: false
      t.timestamp :end_date, null: false
      t.boolean :is_active, default: true
      
      # Applicability
      t.text :applicable_categories # Category IDs (TEXT for SQLite)
      t.text :applicable_products # Product IDs (TEXT for SQLite)
      t.text :applicable_brands # Brand IDs (TEXT for SQLite)
      
      # Banner & Media
      t.string :banner_image_url, limit: 500
      t.string :thumbnail_url, limit: 500
      
      # Admin
      t.references :created_by, null: true, foreign_key: { to_table: :admins }
      
      t.timestamps
    end
    
    add_index :promotions, :is_active unless index_exists?(:promotions, :is_active)
    add_index :promotions, [:start_date, :end_date] unless index_exists?(:promotions, [:start_date, :end_date])
  end
end

