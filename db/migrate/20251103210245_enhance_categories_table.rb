# Phase 2: Enhance Categories Table
# Adds hierarchical structure, SEO fields, and metadata
class EnhanceCategoriesTable < ActiveRecord::Migration[7.1]
  def up
    # Slug for SEO-friendly URLs
    unless column_exists?(:categories, :slug)
      add_column :categories, :slug, :string
      add_index :categories, :slug, unique: true unless index_exists?(:categories, :slug)
    end

    # Hierarchical structure
    unless column_exists?(:categories, :level)
      add_column :categories, :level, :integer, default: 0
      add_index :categories, :level unless index_exists?(:categories, :level)
    end

    unless column_exists?(:categories, :path)
      add_column :categories, :path, :text
      add_index :categories, :path unless index_exists?(:categories, :path)
    end

    unless column_exists?(:categories, :sort_order)
      add_column :categories, :sort_order, :integer, default: 0
      add_index :categories, :sort_order unless index_exists?(:categories, :sort_order)
    end

    # Content fields
    unless column_exists?(:categories, :short_description)
      add_column :categories, :short_description, :text
    end

    unless column_exists?(:categories, :image_url)
      add_column :categories, :image_url, :string
    end

    unless column_exists?(:categories, :banner_url)
      add_column :categories, :banner_url, :string
    end

    unless column_exists?(:categories, :icon_url)
      add_column :categories, :icon_url, :string
    end

    # SEO fields
    unless column_exists?(:categories, :meta_title)
      add_column :categories, :meta_title, :string
    end

    unless column_exists?(:categories, :meta_description)
      add_column :categories, :meta_description, :text
    end

    unless column_exists?(:categories, :meta_keywords)
      add_column :categories, :meta_keywords, :text
    end

    # Status and metrics
    unless column_exists?(:categories, :featured)
      add_column :categories, :featured, :boolean, default: false
      add_index :categories, :featured unless index_exists?(:categories, :featured)
    end

    unless column_exists?(:categories, :products_count)
      add_column :categories, :products_count, :integer, default: 0
    end

    unless column_exists?(:categories, :active_products_count)
      add_column :categories, :active_products_count, :integer, default: 0
    end

    # Requirements (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:categories, :require_brand)
      add_column :categories, :require_brand, :text, default: '{}'
    end

    unless column_exists?(:categories, :require_attributes)
      add_column :categories, :require_attributes, :text, default: '[]'
    end

    # Data migration: Generate slugs
    execute <<-SQL
      UPDATE categories
      SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '''', ''))
      WHERE slug IS NULL OR slug = '';
    SQL

    # Calculate level and path for existing categories (using SQL to avoid model dependencies)
    # Note: This is a simplified calculation - full hierarchy calculation may need a rake task
    execute <<-SQL
      UPDATE categories
      SET level = 0,
          path = name
      WHERE parent_id IS NULL;
    SQL

    execute <<-SQL
      UPDATE categories
      SET level = 1,
          path = (SELECT name FROM categories c WHERE c.id = categories.parent_id) || ' > ' || categories.name
      WHERE parent_id IS NOT NULL;
    SQL

    # Initialize counts
    execute <<-SQL
      UPDATE categories
      SET products_count = (
        SELECT COUNT(*) FROM products WHERE products.category_id = categories.id
      ),
      active_products_count = (
        SELECT COUNT(*) FROM products 
        WHERE products.category_id = categories.id 
        AND products.status = 1
      );
    SQL
  end

  def down
    remove_column :categories, :slug if column_exists?(:categories, :slug)
    remove_column :categories, :level if column_exists?(:categories, :level)
    remove_column :categories, :path if column_exists?(:categories, :path)
    remove_column :categories, :sort_order if column_exists?(:categories, :sort_order)
    remove_column :categories, :short_description if column_exists?(:categories, :short_description)
    remove_column :categories, :image_url if column_exists?(:categories, :image_url)
    remove_column :categories, :banner_url if column_exists?(:categories, :banner_url)
    remove_column :categories, :icon_url if column_exists?(:categories, :icon_url)
    remove_column :categories, :meta_title if column_exists?(:categories, :meta_title)
    remove_column :categories, :meta_description if column_exists?(:categories, :meta_description)
    remove_column :categories, :meta_keywords if column_exists?(:categories, :meta_keywords)
    remove_column :categories, :featured if column_exists?(:categories, :featured)
    remove_column :categories, :products_count if column_exists?(:categories, :products_count)
    remove_column :categories, :active_products_count if column_exists?(:categories, :active_products_count)
    remove_column :categories, :require_brand if column_exists?(:categories, :require_brand)
    remove_column :categories, :require_attributes if column_exists?(:categories, :require_attributes)
  end
end
