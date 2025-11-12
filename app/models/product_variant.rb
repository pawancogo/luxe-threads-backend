class ProductVariant < ApplicationRecord
  # Associations - only associations
  belongs_to :product
  has_many :product_images, dependent: :destroy
  has_many :product_variant_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_variant_attributes
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many_attached :images

  # Callback replaced by service - generate SKU if blank
  before_validation :ensure_sku, on: :create

  # Validations
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Phase 2: Associations
  belongs_to :primary_image, class_name: 'ProductImage', foreign_key: 'primary_image_id', optional: true

  # Phase 2: Scopes
  scope :available, -> { where(is_available: true) }
  scope :low_stock, -> { where(is_low_stock: true) }
  scope :out_of_stock, -> { where(out_of_stock: true) }
  scope :unavailable, -> { where(is_available: false) }
  scope :search_by_sku, ->(term) { where('sku LIKE ?', "%#{term}%") if term.present? }
  scope :with_full_details, -> { includes(:product_images, product_variant_attributes: { attribute_value: :attribute_type }) }
  scope :apply_variant_status_filter, ->(status) {
    case status
    when 'available' then available
    when 'unavailable' then unavailable
    when 'low_stock' then low_stock
    when 'out_of_stock' then out_of_stock
    else all
    end
  }

  # Phase 2: Callbacks - delegate to service
  before_save :update_availability_flags
  after_save :update_product_inventory_metrics

  # Include JSON parsing concern
  include JsonParseable
  
  # Phase 2: JSON field helpers using concern
  json_hash_parser :variant_attributes

  # Include value object concerns
  include Pricable
  include Inventoriable

  # Business logic methods using value objects
  def available?
    in_stock? && is_available
  end

  # Override to use price object
  def current_price
    price_object.final
  end

  # Phase 2: Update availability flags (delegates to service)
  def update_availability_flags
    service = Products::VariantAvailabilityService.new(self)
    service.call
    # Service updates the flags directly on the variant
  end

  # Phase 2: Update product inventory metrics when variant changes (delegates to service)
  def update_product_inventory_metrics
    # This is handled by VariantAvailabilityService
    # Keeping for backward compatibility but logic is in service
  end

  private

  def ensure_sku
    return if sku.present?
    self.sku = SkuGenerationService.generate_for(self)
  end
end