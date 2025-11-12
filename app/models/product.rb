class Product < ApplicationRecord
  extend SearchManager
  
  # Include shared behavior
  include Auditable
  include PriceAggregatable
  include InventoryAggregatable
  
  # Search manager configuration
  search_manager on: [:name, :description], aggs_on: [:status, :is_featured, :category_id, :supplier_profile_id], range_on: :base_price

  # Associations - only associations
  belongs_to :supplier_profile
  belongs_to :category
  belongs_to :brand
  belongs_to :verified_by_admin, class_name: 'Admin', optional: true

  has_many :product_variants, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_attributes
  has_many :product_images, dependent: :destroy

  # Enums
  enum :status, { pending: 0, active: 1, rejected: 2, archived: 3 }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :slug, uniqueness: true, allow_nil: true

  # Ecommerce-specific scopes
  scope :active, -> { where(status: :active) }
  scope :featured, -> { where(is_featured: true) }
  scope :bestsellers, -> { where(is_bestseller: true) }
  scope :new_arrivals, -> { where(is_new_arrival: true) }
  scope :trending, -> { where(is_trending: true) }
  scope :published, -> { where.not(published_at: nil) }
  scope :pending, -> { where(status: :pending) }
  scope :for_supplier_profile, ->(profile_id) { where(supplier_profile_id: profile_id) if profile_id.present? }
  scope :with_status, ->(status) { where(status: status) if status.present? }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) if brand_id.present? }
  scope :by_slug, ->(slug) { where(slug: slug) if slug.present? }
  scope :by_supplier, ->(supplier_id) { where(supplier_profile_id: supplier_id) if supplier_id.present? }
  scope :created_from, ->(date) { where('created_at >= ?', date) if date.present? }
  scope :created_to, ->(date) { where('created_at <= ?', date) if date.present? }
  scope :created_between, ->(from, to) { created_from(from).created_to(to) }
  scope :admin_listing, -> { includes(:supplier_profile, :category, :brand, :product_variants, verified_by_admin: []) }
  
  # Eager loading scopes
  scope :with_variants, -> { includes(:product_variants) }
  scope :with_images, -> { includes(product_variants: :product_images) }
  scope :with_attributes, -> { includes(product_variants: { product_variant_attributes: { attribute_value: :attribute_type } }) }
  scope :with_product_attributes, -> { includes(product_attributes: { attribute_value: :attribute_type }) }
  scope :with_brand_and_category, -> { includes(:brand, :category) }
  scope :with_full_details, -> { includes(:brand, :category, :supplier_profile, product_variants: [:product_images, :product_variant_attributes, attribute_values: :attribute_type], reviews: :user) }
  
  # Search scope - database-agnostic
  scope :search_by_term, ->(term) {
    return none if term.blank?
    search_term = "%#{term}%"
    if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
      where(
        'name ILIKE ? OR description ILIKE ? OR short_description ILIKE ? OR slug ILIKE ?',
        search_term, search_term, search_term, search_term
      )
    else
      where(
        'UPPER(name) LIKE UPPER(?) OR UPPER(description) LIKE UPPER(?) OR UPPER(short_description) LIKE UPPER(?) OR UPPER(slug) LIKE UPPER(?)',
        search_term, search_term, search_term, search_term
      )
    end
  }

  # Configure concerns
  price_aggregatable_on :product_variants, price_columns: [:price, :discounted_price, :mrp]
  inventory_aggregatable_on :product_variants

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_save :update_aggregated_prices, if: -> { product_variants.any? }
  after_update :update_inventory_metrics
  after_update :invalidate_product_cache
  after_destroy :invalidate_product_cache

  # Include JSON parsing concern
  include JsonParseable
  
  # Phase 2: JSON field helpers using concern
  json_array_parser :highlights, :search_keywords, :tags
  json_hash_parser :product_attributes, :rating_distribution

  # Price and inventory aggregation handled by concerns
  # available? method provided by InventoryAggregatable
  # current_price method provided by PriceAggregatable

  private

  # Invalidate product cache when product is updated or destroyed
  def invalidate_product_cache
    # Only invalidate if caching feature is enabled
    return unless FeatureFlags.check(:caching)
    
    # Clear product detail cache
    Rails.cache.delete("public_product:#{id}")
    Rails.cache.delete("public_product:#{slug}") if slug.present?
    
    # Clear listing cache (pattern match for all product listing caches)
    # Note: This is a simple approach. For production, consider using cache tags or versioning
    Rails.cache.delete_matched("public_products:*") if Rails.cache.respond_to?(:delete_matched)
  end

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  # Note: Presentation logic is handled by serializers (ProductSerializer, PublicProductSerializer)
  # Search indexing logic is handled by SearchManager concern
end