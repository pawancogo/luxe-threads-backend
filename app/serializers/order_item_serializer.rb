# frozen_string_literal: true

# Serializer for OrderItem API responses
# Follows vendor-backend ActiveSerializer pattern
# Options from parent serializer are automatically available via options method
class OrderItemSerializer < BaseSerializer
  attributes :id, :product_variant_id, :product_name, :product_image_url, 
             :quantity, :currency, :fulfillment_status

  # Can access parent options in nested serializer
  # Example: options[:include_product_details] from OrderSerializer
  has_one :product_variant, serializer: ProductVariantSerializer, if: :product_variant_loaded?

  def attributes(*args)
    result = super
    result[:sku] = object.product_variant&.sku
    result[:price_at_purchase] = format_price(object.price_at_purchase)
    result[:discounted_price] = format_price(object.discounted_price)
    result[:final_price] = format_price(object.final_price)
    result[:is_returnable] = format_boolean(object.is_returnable)
    result[:product_variant_attributes] = parse_json_attributes(object.product_variant_attributes)
    result[:currency] ||= 'INR'
    
    # Access options passed from parent serializer
    result[:include_product_details] = serialize_product_details if options[:include_product_details]
    
    result
  end

  def product_variant_loaded?
    object.association(:product_variant).loaded? || options[:include_product_variant]
  end

  private

  def parse_json_attributes(json_string)
    return [] unless json_string.present?
    JSON.parse(json_string) rescue []
  end

  def serialize_product_details
    return {} unless object.respond_to?(:product_variant) && object.product_variant
    variant = object.product_variant
    {
      product_id: variant.product_id,
      product_name: variant.product&.name,
      brand: variant.product&.brand&.name,
      category: variant.product&.category&.name
    }
  end
end
