class AttributeValue < ApplicationRecord
  belongs_to :attribute_type
  has_many :product_variant_attributes, dependent: :destroy
  has_many :product_variants, through: :product_variant_attributes

  validates :value, presence: true
  validates :value, uniqueness: { scope: :attribute_type_id, message: "already exists for this attribute type" }

  # Scope to get values for a specific attribute type
  scope :for_type, ->(type_name) { joins(:attribute_type).where(attribute_types: { name: type_name }) }

  # Check if this is a predefined value
  def predefined?
    attribute_type&.predefined? && attribute_type.predefined_values.include?(value)
  end
end
