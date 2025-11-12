# frozen_string_literal: true

# Serializer for ProductVariant API responses
# Handles formatting of variant data with images and attributes
class ProductVariantSerializer < BaseSerializer
  attributes :id, :sku, :price, :discounted_price, :stock_quantity, 
             :weight_kg, :available, :current_price, :images, :attributes,
             :created_at, :updated_at

  def price
    format_price(object.price)
  end

  def discounted_price
    format_price(object.discounted_price)
  end

  def weight_kg
    format_price(object.weight_kg)
  end

  def available
    object.available?
  end

  def current_price
    format_price(object.current_price)
  end

  def created_at
    format_date(object.created_at)
  end

  def updated_at
    format_date(object.updated_at)
  end

  def images
    object.product_images.order(:display_order).map do |image|
      {
        id: image.id,
        url: image.image_url,
        alt_text: image.alt_text,
        display_order: image.display_order
      }
    end
  end

  def attributes
    object.product_variant_attributes.includes(attribute_value: :attribute_type).map do |pva|
      attr_data = {
        attribute_type: pva.attribute_value.attribute_type.name,
        attribute_value: pva.attribute_value.value
      }
      
      # Add color hex code if this is a color attribute
      if pva.attribute_value.attribute_type.name.downcase == 'color'
        hex_code = ColorHexMap.hex_for(pva.attribute_value.value) if defined?(ColorHexMap)
        attr_data[:hex_code] = hex_code if hex_code
      end
      
      attr_data
    end
  end
end

