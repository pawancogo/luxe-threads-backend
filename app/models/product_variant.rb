class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :product_images, dependent: :destroy
  has_many :product_variant_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_variant_attributes
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many_attached :images

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end