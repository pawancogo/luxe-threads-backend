# Phase 2: Enhance Products Table
# Adds SEO fields, product metadata, metrics, and tracking
class EnhanceProductsTable < ActiveRecord::Migration[7.1]
  def up
    # Slug for SEO-friendly URLs
    unless column_exists?(:products, :slug)
      add_column :products, :slug, :string
      add_index :products, :slug, unique: true unless index_exists?(:products, :slug)
    end

    # Content fields
    unless column_exists?(:products, :short_description)
      add_column :products, :short_description, :text
    end

    # Highlights (stored as TEXT for SQLite, JSON array string)
    unless column_exists?(:products, :highlights)
      add_column :products, :highlights, :text, default: '[]'
    end

    # Product type and status tracking
    unless column_exists?(:products, :product_type)
      add_column :products, :product_type, :string
      add_index :products, :product_type unless index_exists?(:products, :product_type)
    end

    unless column_exists?(:products, :status_changed_at)
      add_column :products, :status_changed_at, :datetime
    end

    unless column_exists?(:products, :status_changed_by_id)
      add_column :products, :status_changed_by_id, :integer
      add_index :products, :status_changed_by_id unless index_exists?(:products, :status_changed_by_id)
    end

    # SEO fields
    unless column_exists?(:products, :meta_title)
      add_column :products, :meta_title, :string
    end

    unless column_exists?(:products, :meta_description)
      add_column :products, :meta_description, :text
    end

    unless column_exists?(:products, :meta_keywords)
      add_column :products, :meta_keywords, :text
    end

    # Search and discovery
    # Search keywords (stored as TEXT for SQLite, JSON array string)
    unless column_exists?(:products, :search_keywords)
      add_column :products, :search_keywords, :text, default: '[]'
    end

    # Tags (stored as TEXT for SQLite, JSON array string)
    unless column_exists?(:products, :tags)
      add_column :products, :tags, :text, default: '[]'
    end

    # Product attributes (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:products, :product_attributes)
      add_column :products, :product_attributes, :text, default: '{}'
    end

    # Pricing (base prices from variants)
    unless column_exists?(:products, :base_price)
      add_column :products, :base_price, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:products, :base_discounted_price)
      add_column :products, :base_discounted_price, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:products, :base_mrp)
      add_column :products, :base_mrp, :decimal, precision: 10, scale: 2
    end

    # Dimensions and weight
    unless column_exists?(:products, :length_cm)
      add_column :products, :length_cm, :decimal, precision: 8, scale: 2
    end

    unless column_exists?(:products, :width_cm)
      add_column :products, :width_cm, :decimal, precision: 8, scale: 2
    end

    unless column_exists?(:products, :height_cm)
      add_column :products, :height_cm, :decimal, precision: 8, scale: 2
    end

    unless column_exists?(:products, :weight_kg)
      add_column :products, :weight_kg, :decimal, precision: 8, scale: 3
    end

    # Rating distribution (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:products, :rating_distribution)
      add_column :products, :rating_distribution, :text, default: '{}'
    end

    # Analytics metrics
    unless column_exists?(:products, :total_clicks_count)
      add_column :products, :total_clicks_count, :integer, default: 0
    end

    unless column_exists?(:products, :conversion_rate)
      add_column :products, :conversion_rate, :decimal, precision: 5, scale: 2, default: 0.0
    end

    # Inventory metrics
    unless column_exists?(:products, :total_stock_quantity)
      add_column :products, :total_stock_quantity, :integer, default: 0
    end

    unless column_exists?(:products, :low_stock_variants_count)
      add_column :products, :low_stock_variants_count, :integer, default: 0
    end

    # Flags
    unless column_exists?(:products, :is_featured)
      add_column :products, :is_featured, :boolean, default: false
      add_index :products, :is_featured unless index_exists?(:products, :is_featured)
    end

    unless column_exists?(:products, :is_bestseller)
      add_column :products, :is_bestseller, :boolean, default: false
      add_index :products, :is_bestseller unless index_exists?(:products, :is_bestseller)
    end

    unless column_exists?(:products, :is_new_arrival)
      add_column :products, :is_new_arrival, :boolean, default: false
      add_index :products, :is_new_arrival unless index_exists?(:products, :is_new_arrival)
    end

    unless column_exists?(:products, :is_trending)
      add_column :products, :is_trending, :boolean, default: false
      add_index :products, :is_trending unless index_exists?(:products, :is_trending)
    end

    unless column_exists?(:products, :published_at)
      add_column :products, :published_at, :datetime
      add_index :products, :published_at unless index_exists?(:products, :published_at)
    end

    # Data migration: Generate slugs
    execute <<-SQL
      UPDATE products
      SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '''', ''))
      WHERE slug IS NULL OR slug = '';
    SQL

    # Initialize metrics (will be calculated by background jobs)
    execute <<-SQL
      UPDATE products
      SET total_stock_quantity = (
        SELECT COALESCE(SUM(stock_quantity), 0) 
        FROM product_variants 
        WHERE product_variants.product_id = products.id
      );
    SQL
  end

  def down
    remove_column :products, :slug if column_exists?(:products, :slug)
    remove_column :products, :short_description if column_exists?(:products, :short_description)
    remove_column :products, :highlights if column_exists?(:products, :highlights)
    remove_column :products, :product_type if column_exists?(:products, :product_type)
    remove_column :products, :status_changed_at if column_exists?(:products, :status_changed_at)
    remove_column :products, :status_changed_by_id if column_exists?(:products, :status_changed_by_id)
    remove_column :products, :meta_title if column_exists?(:products, :meta_title)
    remove_column :products, :meta_description if column_exists?(:products, :meta_description)
    remove_column :products, :meta_keywords if column_exists?(:products, :meta_keywords)
    remove_column :products, :search_keywords if column_exists?(:products, :search_keywords)
    remove_column :products, :tags if column_exists?(:products, :tags)
    remove_column :products, :product_attributes if column_exists?(:products, :product_attributes)
    remove_column :products, :base_price if column_exists?(:products, :base_price)
    remove_column :products, :base_discounted_price if column_exists?(:products, :base_discounted_price)
    remove_column :products, :base_mrp if column_exists?(:products, :base_mrp)
    remove_column :products, :length_cm if column_exists?(:products, :length_cm)
    remove_column :products, :width_cm if column_exists?(:products, :width_cm)
    remove_column :products, :height_cm if column_exists?(:products, :height_cm)
    remove_column :products, :weight_kg if column_exists?(:products, :weight_kg)
    remove_column :products, :rating_distribution if column_exists?(:products, :rating_distribution)
    remove_column :products, :total_clicks_count if column_exists?(:products, :total_clicks_count)
    remove_column :products, :conversion_rate if column_exists?(:products, :conversion_rate)
    remove_column :products, :total_stock_quantity if column_exists?(:products, :total_stock_quantity)
    remove_column :products, :low_stock_variants_count if column_exists?(:products, :low_stock_variants_count)
    remove_column :products, :is_featured if column_exists?(:products, :is_featured)
    remove_column :products, :is_bestseller if column_exists?(:products, :is_bestseller)
    remove_column :products, :is_new_arrival if column_exists?(:products, :is_new_arrival)
    remove_column :products, :is_trending if column_exists?(:products, :is_trending)
    remove_column :products, :published_at if column_exists?(:products, :published_at)
  end
end
