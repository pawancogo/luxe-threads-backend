class ProductVariantAttribute < ApplicationRecord
  belongs_to :product_variant
  belongs_to :attribute_value
end
