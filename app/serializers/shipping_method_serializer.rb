# frozen_string_literal: true

# Serializer for ShippingMethod API responses
class ShippingMethodSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      name: object.name,
      code: object.code,
      description: object.description,
      provider: object.provider,
      base_charge: format_price(object.base_charge),
      per_kg_charge: format_price(object.per_kg_charge),
      free_shipping_above: format_price(object.free_shipping_above),
      estimated_days_min: object.estimated_days_min,
      estimated_days_max: object.estimated_days_max,
      is_cod_available: format_boolean(object.is_cod_available)
    }
  end

  # Detailed version with all fields
  def detailed
    serialize.merge(
      is_active: format_boolean(object.is_active),
      available_pincodes: object.available_pincodes_list || [],
      excluded_pincodes: object.excluded_pincodes_list || [],
      created_at: format_date(object.created_at),
      updated_at: format_date(object.updated_at)
    )
  end
end


