# Phase 2: Enhance Product Variants Table
# Adds inventory tracking, barcode, pricing, and availability fields
class EnhanceProductVariantsTable < ActiveRecord::Migration[7.1]
  def up
    # Barcode and identification
    unless column_exists?(:product_variants, :barcode)
      add_column :product_variants, :barcode, :string
      add_index :product_variants, :barcode unless index_exists?(:product_variants, :barcode)
    end

    unless column_exists?(:product_variants, :ean_code)
      add_column :product_variants, :ean_code, :string
    end

    unless column_exists?(:product_variants, :isbn)
      add_column :product_variants, :isbn, :string
    end

    # Pricing fields
    unless column_exists?(:product_variants, :cost_price)
      add_column :product_variants, :cost_price, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:product_variants, :mrp)
      add_column :product_variants, :mrp, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:product_variants, :currency)
      add_column :product_variants, :currency, :string, default: 'INR'
    end

    # Inventory tracking
    unless column_exists?(:product_variants, :reserved_quantity)
      add_column :product_variants, :reserved_quantity, :integer, default: 0
    end

    # Available quantity (calculated: stock_quantity - reserved_quantity)
    # Note: In SQLite, we'll use a virtual column or calculate in application
    # For now, we'll add it as a regular column that can be updated
    unless column_exists?(:product_variants, :available_quantity)
      add_column :product_variants, :available_quantity, :integer, default: 0
      add_index :product_variants, :available_quantity unless index_exists?(:product_variants, :available_quantity)
    end

    # Stock thresholds
    unless column_exists?(:product_variants, :low_stock_threshold)
      add_column :product_variants, :low_stock_threshold, :integer, default: 10
    end

    # Flags (calculated in application)
    unless column_exists?(:product_variants, :is_low_stock)
      add_column :product_variants, :is_low_stock, :boolean, default: false
      add_index :product_variants, :is_low_stock unless index_exists?(:product_variants, :is_low_stock)
    end

    unless column_exists?(:product_variants, :out_of_stock)
      add_column :product_variants, :out_of_stock, :boolean, default: false
      add_index :product_variants, :out_of_stock unless index_exists?(:product_variants, :out_of_stock)
    end

    unless column_exists?(:product_variants, :is_available)
      add_column :product_variants, :is_available, :boolean, default: true
      add_index :product_variants, :is_available unless index_exists?(:product_variants, :is_available)
    end

    # Variant attributes (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:product_variants, :variant_attributes)
      add_column :product_variants, :variant_attributes, :text, default: '{}'
    end

    # Primary image reference
    unless column_exists?(:product_variants, :primary_image_id)
      add_column :product_variants, :primary_image_id, :integer
      add_index :product_variants, :primary_image_id unless index_exists?(:product_variants, :primary_image_id)
    end

    # Return tracking
    unless column_exists?(:product_variants, :total_returned)
      add_column :product_variants, :total_returned, :integer, default: 0
    end

    unless column_exists?(:product_variants, :total_refunded)
      add_column :product_variants, :total_refunded, :integer, default: 0
    end

    # Data migration: Initialize available_quantity and flags
    execute <<-SQL
      UPDATE product_variants
      SET available_quantity = COALESCE(stock_quantity, 0) - COALESCE(reserved_quantity, 0),
          is_low_stock = CASE 
            WHEN COALESCE(stock_quantity, 0) - COALESCE(reserved_quantity, 0) <= COALESCE(low_stock_threshold, 10) 
            THEN 1 ELSE 0 
          END,
          out_of_stock = CASE 
            WHEN COALESCE(stock_quantity, 0) - COALESCE(reserved_quantity, 0) <= 0 
            THEN 1 ELSE 0 
          END,
          is_available = CASE 
            WHEN COALESCE(stock_quantity, 0) - COALESCE(reserved_quantity, 0) > 0 
            THEN 1 ELSE 0 
          END;
    SQL

    # Set primary_image_id from first product_image
    execute <<-SQL
      UPDATE product_variants
      SET primary_image_id = (
        SELECT id FROM product_images 
        WHERE product_images.product_variant_id = product_variants.id 
        ORDER BY product_images.display_order ASC 
        LIMIT 1
      )
      WHERE primary_image_id IS NULL;
    SQL
  end

  def down
    remove_column :product_variants, :barcode if column_exists?(:product_variants, :barcode)
    remove_column :product_variants, :ean_code if column_exists?(:product_variants, :ean_code)
    remove_column :product_variants, :isbn if column_exists?(:product_variants, :isbn)
    remove_column :product_variants, :cost_price if column_exists?(:product_variants, :cost_price)
    remove_column :product_variants, :mrp if column_exists?(:product_variants, :mrp)
    remove_column :product_variants, :currency if column_exists?(:product_variants, :currency)
    remove_column :product_variants, :reserved_quantity if column_exists?(:product_variants, :reserved_quantity)
    remove_column :product_variants, :available_quantity if column_exists?(:product_variants, :available_quantity)
    remove_column :product_variants, :low_stock_threshold if column_exists?(:product_variants, :low_stock_threshold)
    remove_column :product_variants, :is_low_stock if column_exists?(:product_variants, :is_low_stock)
    remove_column :product_variants, :out_of_stock if column_exists?(:product_variants, :out_of_stock)
    remove_column :product_variants, :is_available if column_exists?(:product_variants, :is_available)
    remove_column :product_variants, :variant_attributes if column_exists?(:product_variants, :variant_attributes)
    remove_column :product_variants, :primary_image_id if column_exists?(:product_variants, :primary_image_id)
    remove_column :product_variants, :total_returned if column_exists?(:product_variants, :total_returned)
    remove_column :product_variants, :total_refunded if column_exists?(:product_variants, :total_refunded)
  end
end
