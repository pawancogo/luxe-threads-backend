# frozen_string_literal: true

# Repository pattern for product data access
# Abstracts database operations from business logic
class ProductRepository
  def initialize(query = ProductQuery.new)
    @query = query
  end

  def find(id)
    Product.find(id)
  end

  def find_by_supplier_profile(profile_id, id)
    ProductQuery.new.for_supplier_profile(profile_id).with_variants.with_images.with_attributes.with_product_attributes.find(id)
  end

  def all_for_supplier_profile(profile_id)
    ProductQuery.new.for_supplier_profile(profile_id).with_variants.with_images.with_attributes.with_product_attributes.result
  end

  def pending_for_supplier_profile(profile_id)
    ProductQuery.new
      .for_supplier_profile(profile_id)
      .pending
      .with_variants
      .result
  end

  def active_products
    ProductQuery.new.active.with_variants.with_images.with_attributes.with_product_attributes.result
  end

  def search_products(term, filters = {})
    query = ProductQuery.new.active.with_variants.with_images.with_attributes.with_product_attributes.search(term)
    
    query = query.by_category(filters[:category_id]) if filters[:category_id].present?
    query = query.by_brand(filters[:brand_id]) if filters[:brand_id].present?
    
    query.result
  end

  def create(attributes)
    Product.create(attributes)
  end

  def update(product, attributes)
    product.update(attributes)
  end

  def destroy(product)
    product.destroy
  end
end

