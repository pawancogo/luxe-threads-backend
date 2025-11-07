class Product < ApplicationRecord
  extend SearchManager
  
  # Include shared behavior
  include Auditable
  
  # Search manager configuration
  search_manager on: [:name, :description, :sku], aggs_on: [:status, :is_featured, :category_id]

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

  # Phase 2: Scopes
  scope :active, -> { where(status: :active) }
  scope :featured, -> { where(is_featured: true) }
  scope :bestsellers, -> { where(is_bestseller: true) }
  scope :new_arrivals, -> { where(is_new_arrival: true) }
  scope :trending, -> { where(is_trending: true) }
  scope :published, -> { where.not(published_at: nil) }

  # Phase 2: Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_save :update_base_prices, if: -> { product_variants.any? }
  after_update :update_inventory_metrics
  after_update :invalidate_product_cache
  after_destroy :invalidate_product_cache

  # Phase 2: JSON field helpers
  def highlights_array
    return [] if highlights.blank?
    JSON.parse(highlights) rescue []
  end

  def search_keywords_array
    return [] if search_keywords.blank?
    JSON.parse(search_keywords) rescue []
  end

  def tags_array
    return [] if tags.blank?
    JSON.parse(tags) rescue []
  end

  def product_attributes_hash
    return {} if product_attributes.blank?
    JSON.parse(product_attributes) rescue {}
  end

  def rating_distribution_hash
    return {} if rating_distribution.blank?
    JSON.parse(rating_distribution) rescue {}
  end

  # Phase 2: Update base prices from variants
  def update_base_prices
    prices = product_variants.pluck(:price).compact
    discounted_prices = product_variants.pluck(:discounted_price).compact
    mrps = product_variants.pluck(:mrp).compact

    self.base_price = prices.min if prices.any?
    self.base_discounted_price = discounted_prices.min if discounted_prices.any?
    self.base_mrp = mrps.max if mrps.any?
  end

  # Phase 2: Update inventory metrics
  def update_inventory_metrics
    self.total_stock_quantity = product_variants.sum(:stock_quantity) || 0
    self.low_stock_variants_count = product_variants.where(is_low_stock: true).count
    save if changed?
  end

  # Phase 2: Business logic
  def available?
    total_stock_quantity > 0
  end

  def current_price
    base_discounted_price || base_price || product_variants.minimum(:discounted_price) || product_variants.minimum(:price)
  end

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

  # Presentation logic moved to ProductPresenter
  # Search logic can be moved to SearchService if needed
  def search_data
    {
      id: id,
      name: name,
      description: description,
      status: status,
      brand_name: brand.name,
      category_name: category.name,
      supplier_name: supplier_profile.company_name,
      variants: product_variants.map do |variant|
        {
          price: variant.price,
          discounted_price: variant.discounted_price,
        }
      end
    }
  end
end