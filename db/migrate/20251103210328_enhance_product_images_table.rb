# Phase 2: Enhance Product Images Table
# Adds multiple image sizes, metadata, and product-level images
class EnhanceProductImagesTable < ActiveRecord::Migration[7.1]
  def up
    # Note: Making product_variant_id nullable requires table recreation in SQLite
    # For now, we'll keep it required and add product_id as an additional field
    # The model can handle both cases

    # Add product_id if not exists
    unless column_exists?(:product_images, :product_id)
      add_column :product_images, :product_id, :integer
      add_index :product_images, :product_id unless index_exists?(:product_images, :product_id)
    end

    # Multiple image sizes
    unless column_exists?(:product_images, :thumbnail_url)
      add_column :product_images, :thumbnail_url, :string
    end

    unless column_exists?(:product_images, :medium_url)
      add_column :product_images, :medium_url, :string
    end

    unless column_exists?(:product_images, :large_url)
      add_column :product_images, :large_url, :string
    end

    # Image metadata
    unless column_exists?(:product_images, :image_type)
      add_column :product_images, :image_type, :string
      add_index :product_images, :image_type unless index_exists?(:product_images, :image_type)
    end

    unless column_exists?(:product_images, :color_dominant)
      add_column :product_images, :color_dominant, :string
    end

    # File metadata
    unless column_exists?(:product_images, :file_size_bytes)
      add_column :product_images, :file_size_bytes, :integer
    end

    unless column_exists?(:product_images, :width_pixels)
      add_column :product_images, :width_pixels, :integer
    end

    unless column_exists?(:product_images, :height_pixels)
      add_column :product_images, :height_pixels, :integer
    end

    unless column_exists?(:product_images, :mime_type)
      add_column :product_images, :mime_type, :string
    end

    # Data migration: Set product_id from variant's product
    execute <<-SQL
      UPDATE product_images
      SET product_id = (
        SELECT product_id FROM product_variants 
        WHERE product_variants.id = product_images.product_variant_id
      )
      WHERE product_id IS NULL AND product_variant_id IS NOT NULL;
    SQL
  end

  def down
    remove_column :product_images, :product_id if column_exists?(:product_images, :product_id)
    remove_column :product_images, :thumbnail_url if column_exists?(:product_images, :thumbnail_url)
    remove_column :product_images, :medium_url if column_exists?(:product_images, :medium_url)
    remove_column :product_images, :large_url if column_exists?(:product_images, :large_url)
    remove_column :product_images, :image_type if column_exists?(:product_images, :image_type)
    remove_column :product_images, :color_dominant if column_exists?(:product_images, :color_dominant)
    remove_column :product_images, :file_size_bytes if column_exists?(:product_images, :file_size_bytes)
    remove_column :product_images, :width_pixels if column_exists?(:product_images, :width_pixels)
    remove_column :product_images, :height_pixels if column_exists?(:product_images, :height_pixels)
    remove_column :product_images, :mime_type if column_exists?(:product_images, :mime_type)
  end
end
