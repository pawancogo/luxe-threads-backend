# frozen_string_literal: true

# Serializer for AttributeType API responses
class AttributeTypeSerializer < BaseSerializer
  attributes :id, :name, :level, :values

  def level
    is_product_level = AttributeConstants.product_level?(object.name)
    is_variant_level = AttributeConstants.variant_level?(object.name)
    
    return 'product' if is_product_level
    return 'variant' if is_variant_level
    nil
  end

  def values
    # Get values - filter Size values by category if category provided
    values_scope = if is_size_type? && options[:category]
      category_size_values = AttributeConstants.size_values_for_category(options[:category].name)
      object.attribute_values.where(value: category_size_values).order(:display_order, :value)
    else
      object.attribute_values.order(:display_order, :value)
    end
    
    values_scope.map do |value|
      value_data = {
        id: value.id,
        value: value.value
      }
      
      # Add color hex code if this is a color attribute type
      if is_color_type?
        hex_code = ColorHexMap.hex_for(value.value)
        value_data[:hex_code] = hex_code if hex_code
      end
      
      value_data
    end
  end

  private

  def is_color_type?
    object.name.downcase == 'color'
  end

  def is_size_type?
    object.name.downcase == 'size'
  end
end

