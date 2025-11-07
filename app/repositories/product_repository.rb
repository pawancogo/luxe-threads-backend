# frozen_string_literal: true

# Repository pattern for product data access
# Abstracts database operations from business logic
class ProductRepository < BaseRepository
  def initialize(query_class: ProductQuery)
    super(Product, query_class: query_class)
  end

  # Find product by ID with eager loading
  def find_with_associations(id)
    query
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .find(id)
  end

  # Find product by supplier profile and ID
  def find_by_supplier_profile(profile_id, id)
    query
      .for_supplier_profile(profile_id)
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .find(id)
  end

  # Get all products for supplier profile
  def all_for_supplier_profile(profile_id)
    query
      .for_supplier_profile(profile_id)
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .result
  end

  # Get pending products for supplier profile
  def pending_for_supplier_profile(profile_id)
    query
      .for_supplier_profile(profile_id)
      .pending
      .with_variants
      .result
  end

  # Get active products with all associations
  def active_products
    query
      .active
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .result
  end

  # Search products with filters
  def search_products(term, filters = {})
    query_obj = query
      .active
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .search(term)
    
    query_obj = query_obj.by_category(filters[:category_id]) if filters[:category_id].present?
    query_obj = query_obj.by_brand(filters[:brand_id]) if filters[:brand_id].present?
    
    query_obj.result
  end

  # Get products by slug (for public API)
  def find_by_slug(slug)
    query
      .by_slug(slug)
      .with_variants
      .with_images
      .with_attributes
      .with_product_attributes
      .first
  end

  private

  # Get query instance
  def query
    @query ||= query_class.new
  end
end

