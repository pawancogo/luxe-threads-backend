class ProductImage < ApplicationRecord
  belongs_to :product_variant

  validates :image_url, presence: true
  validates :display_order, presence: true, numericality: { greater_than_or_equal_to: 0 }
end