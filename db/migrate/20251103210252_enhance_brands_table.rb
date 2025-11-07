# Phase 2: Enhance Brands Table
# Adds SEO fields, metadata, and status tracking
class EnhanceBrandsTable < ActiveRecord::Migration[7.1]
  def up
    # Slug for SEO-friendly URLs
    unless column_exists?(:brands, :slug)
      add_column :brands, :slug, :string
      add_index :brands, :slug, unique: true unless index_exists?(:brands, :slug)
    end

    # Content fields
    unless column_exists?(:brands, :short_description)
      add_column :brands, :short_description, :text
    end

    unless column_exists?(:brands, :banner_url)
      add_column :brands, :banner_url, :string
    end

    # Brand information
    unless column_exists?(:brands, :country_of_origin)
      add_column :brands, :country_of_origin, :string
    end

    unless column_exists?(:brands, :founded_year)
      add_column :brands, :founded_year, :integer
    end

    unless column_exists?(:brands, :website_url)
      add_column :brands, :website_url, :string
    end

    # Status and metrics
    unless column_exists?(:brands, :active)
      add_column :brands, :active, :boolean, default: true
      add_index :brands, :active unless index_exists?(:brands, :active)
    end

    unless column_exists?(:brands, :products_count)
      add_column :brands, :products_count, :integer, default: 0
    end

    unless column_exists?(:brands, :active_products_count)
      add_column :brands, :active_products_count, :integer, default: 0
    end

    # SEO fields
    unless column_exists?(:brands, :meta_title)
      add_column :brands, :meta_title, :string
    end

    unless column_exists?(:brands, :meta_description)
      add_column :brands, :meta_description, :text
    end

    # Data migration: Generate slugs
    execute <<-SQL
      UPDATE brands
      SET slug = LOWER(REPLACE(name, ' ', '-'))
      WHERE slug IS NULL OR slug = '';
    SQL

    # Initialize counts
    execute <<-SQL
      UPDATE brands
      SET products_count = (
        SELECT COUNT(*) FROM products WHERE products.brand_id = brands.id
      ),
      active_products_count = (
        SELECT COUNT(*) FROM products 
        WHERE products.brand_id = brands.id 
        AND products.status = 1
      );
    SQL
  end

  def down
    remove_column :brands, :slug if column_exists?(:brands, :slug)
    remove_column :brands, :short_description if column_exists?(:brands, :short_description)
    remove_column :brands, :banner_url if column_exists?(:brands, :banner_url)
    remove_column :brands, :country_of_origin if column_exists?(:brands, :country_of_origin)
    remove_column :brands, :founded_year if column_exists?(:brands, :founded_year)
    remove_column :brands, :website_url if column_exists?(:brands, :website_url)
    remove_column :brands, :active if column_exists?(:brands, :active)
    remove_column :brands, :products_count if column_exists?(:brands, :products_count)
    remove_column :brands, :active_products_count if column_exists?(:brands, :active_products_count)
    remove_column :brands, :meta_title if column_exists?(:brands, :meta_title)
    remove_column :brands, :meta_description if column_exists?(:brands, :meta_description)
  end
end
