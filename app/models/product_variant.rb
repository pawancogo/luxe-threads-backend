class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :product_images, dependent: :destroy
  has_many :product_variant_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_variant_attributes
  has_many_attached :images
end