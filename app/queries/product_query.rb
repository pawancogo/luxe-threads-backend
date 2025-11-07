# frozen_string_literal: true

# Query object for complex product queries
# Extracts query logic from controllers and models
class ProductQuery < BaseQuery
  def initialize(scope = nil)
    super(scope)
  end

  protected

  def default_scope
    Product.all
  end

  public

  # Chainable query methods
  def for_supplier_profile(profile_id)
    @scope = scope.where(supplier_profile_id: profile_id)
    self
  end

  def with_status(status)
    @scope = scope.where(status: status) if status.present?
    self
  end

  def active
    @scope = scope.where(status: :active)
    self
  end

  def pending
    @scope = scope.where(status: :pending)
    self
  end

  def by_category(category_id)
    @scope = scope.where(category_id: category_id) if category_id.present?
    self
  end

  def by_brand(brand_id)
    @scope = scope.where(brand_id: brand_id) if brand_id.present?
    self
  end

  def with_variants
    @scope = scope.includes(:product_variants)
    self
  end

  def with_images
    @scope = scope.includes(product_variants: :product_images)
    self
  end

  def with_attributes
    @scope = scope.includes(product_variants: { product_variant_attributes: { attribute_value: :attribute_type } })
    self
  end

  def with_product_attributes
    @scope = scope.includes(product_attributes: { attribute_value: :attribute_type })
    self
  end

  def search(term)
    return self if term.blank?
    # Phase 2: Enhanced search including slug, search_keywords, and tags
    @scope = scope.where(
      'name ILIKE ? OR description ILIKE ? OR short_description ILIKE ? OR slug ILIKE ?',
      "%#{term}%",
      "%#{term}%",
      "%#{term}%",
      "%#{term}%"
    )
    self
  end

  # Phase 2: Add Phase 2 scopes
  def featured
    @scope = scope.featured
    self
  end

  def bestsellers
    @scope = scope.bestsellers
    self
  end

  def new_arrivals
    @scope = scope.new_arrivals
    self
  end

  def trending
    @scope = scope.trending
    self
  end

  def published
    @scope = scope.published
    self
  end

  def by_slug(slug)
    @scope = scope.where(slug: slug) if slug.present?
    self
  end

  # Additional product-specific query methods below
end

