# frozen_string_literal: true

# Serializer for Coupon API responses
# Follows vendor-backend ActiveSerializer pattern
class CouponSerializer < BaseSerializer
  attributes :id, :code, :name, :description, :coupon_type, :max_uses, 
             :max_uses_per_user

  def attributes(*args)
    result = super
    result[:discount_value] = format_price(object.discount_value)
    result[:max_discount_amount] = format_price(object.max_discount_amount)
    result[:min_order_amount] = format_price(object.min_order_amount)
    result[:valid_from] = format_date(object.valid_from)
    result[:valid_until] = format_date(object.valid_until)
    result[:is_active] = format_boolean(object.is_active)
    result[:current_uses] = object.current_uses || 0
    result
  end

  # Detailed version with all fields
  def detailed
    result = attributes
    result[:is_new_user_only] = format_boolean(object.is_new_user_only)
    result[:is_first_order_only] = format_boolean(object.is_first_order_only)
    result[:applicable_categories] = object.applicable_categories_list || []
    result[:applicable_products] = object.applicable_products_list || []
    result[:applicable_brands] = object.applicable_brands_list || []
    result[:applicable_suppliers] = object.applicable_suppliers_list || []
    result[:created_at] = format_date(object.created_at)
    result[:updated_at] = format_date(object.updated_at)
    result
  end
end

