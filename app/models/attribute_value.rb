class AttributeValue < ApplicationRecord
  belongs_to :attribute_type
  has_many :product_variant_attributes, dependent: :destroy
  has_many :product_variants, through: :product_variant_attributes
end
