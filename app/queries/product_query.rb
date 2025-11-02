# frozen_string_literal: true

# Query object for complex product queries
# Extracts query logic from controllers and models
class ProductQuery
  attr_reader :scope

  def initialize(scope = Product.all)
    @scope = scope
  end

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
    @scope = scope.where(
      'name ILIKE ? OR description ILIKE ?',
      "%#{term}%",
      "%#{term}%"
    )
    self
  end

  def order_by(column, direction = :asc)
    @scope = scope.order("#{column} #{direction.to_s.upcase}")
    self
  end

  def paginate(page: 1, per_page: 20)
    @scope = scope.page(page).per(per_page)
    self
  end

  # Return the final scope
  def result
    @scope
  end

  # Delegate common methods
  delegate :to_a, :each, :map, :count, :exists?, :find, :find_by, to: :result
end

