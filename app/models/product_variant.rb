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

  # Phase 2: Callbacks
  before_save :update_availability_flags
  after_save :update_product_inventory_metrics

  # Phase 2: JSON field helpers
  def variant_attributes_hash
    return {} if variant_attributes.blank?
    JSON.parse(variant_attributes) rescue {}
  end

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

  # Phase 2: Update availability flags
  def update_availability_flags
    self.available_quantity = (stock_quantity || 0) - (reserved_quantity || 0)
    self.is_low_stock = available_quantity <= (low_stock_threshold || 10)
    self.out_of_stock = available_quantity <= 0
    self.is_available = available_quantity > 0
  end

  # Phase 2: Update product inventory metrics when variant changes
  def update_product_inventory_metrics
    product.update_inventory_metrics if product.present?
  end

  private

  def ensure_sku
    return if sku.present?
    self.sku = SkuGenerationService.generate_for(self)
  end
end