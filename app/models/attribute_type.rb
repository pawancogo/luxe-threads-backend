class AttributeType < ApplicationRecord
  has_many :attribute_values, dependent: :destroy
  has_many :product_variant_attributes, through: :attribute_values
end
