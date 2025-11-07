class AttributeType < ApplicationRecord
  has_many :attribute_values, dependent: :destroy
  has_many :product_variant_attributes, through: :attribute_values

  validates :name, presence: true, uniqueness: true

  # Scope to get common attribute types
  scope :common, -> { where(name: AttributeConstants.attribute_type_names) }

  # Check if this is a predefined attribute type
  def predefined?
    AttributeConstants.attribute_type_exists?(name)
  end

  # Get all predefined values for this attribute type
  def predefined_values
    AttributeConstants.values_for(name)
  end

  # Ensure all predefined values exist
  def ensure_predefined_values!
    return unless predefined?
    
    predefined_values.each do |value_name|
      attribute_values.find_or_create_by!(value: value_name)
    end
  end

  # Phase 2: JSON field helpers
  def applicable_product_types_array
    return [] if applicable_product_types.blank?
    JSON.parse(applicable_product_types) rescue []
  end

  def applicable_categories_array
    return [] if applicable_categories.blank?
    JSON.parse(applicable_categories) rescue []
  end

  def validation_rules_hash
    return {} if validation_rules.blank?
    JSON.parse(validation_rules) rescue {}
  end

  # Phase 2: Scopes
  scope :variant_attributes, -> { where(is_variant_attribute: true) }
  scope :product_attributes, -> { where(is_variant_attribute: false) }
  scope :by_data_type, ->(type) { where(data_type: type) }
end
