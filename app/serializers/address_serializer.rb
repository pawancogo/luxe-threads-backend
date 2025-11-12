# frozen_string_literal: true

# Serializer for Address API responses
# Follows vendor-backend ActiveSerializer pattern
class AddressSerializer < BaseSerializer
  attributes :id, :address_type, :full_name, :phone_number, :alternate_phone,
             :line1, :line2, :city, :state, :postal_code, :country, :landmark,
             :delivery_instructions, :label

  def attributes(*args)
    result = super
    result[:is_default_shipping] = format_boolean(object.is_default_shipping)
    result[:is_default_billing] = format_boolean(object.is_default_billing)
    result[:created_at] = format_date(object.created_at)
    result[:updated_at] = format_date(object.updated_at)
    result
  end
end

