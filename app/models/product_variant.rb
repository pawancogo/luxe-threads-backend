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

  # Business logic methods
  def available?
    stock_quantity > 0
  end

  def current_price
    discounted_price || price
  end

  private

  def ensure_sku
    return if sku.present?
    self.sku = SkuGenerationService.generate_for(self)
  end
end