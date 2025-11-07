# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  belongs_to :product
  belongs_to :attribute_value

  validates :attribute_value_id, uniqueness: { scope: :product_id, message: "already exists for this product" }
end




