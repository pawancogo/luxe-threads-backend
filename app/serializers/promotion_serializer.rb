# frozen_string_literal: true

# Serializer for Promotion API responses
class PromotionSerializer < BaseSerializer
  attributes :id, :name, :description, :promotion_type, :start_date, :end_date,
             :is_active, :is_featured, :discount_percentage, :discount_amount,
             :min_order_amount, :current?, :applicable_categories,
             :applicable_products, :applicable_brands, :applicable_suppliers,
             :max_discount_amount, :created_at, :updated_at

  def discount_percentage
    object.discount_percentage&.to_f
  end

  def discount_amount
    object.discount_amount&.to_f
  end

  def min_order_amount
    object.min_order_amount&.to_f
  end

  def max_discount_amount
    object.max_discount_amount&.to_f
  end

  def current?
    object.current?
  end

  def applicable_categories
    object.applicable_categories_list
  end

  def applicable_products
    object.applicable_products_list
  end

  def applicable_brands
    object.applicable_brands_list
  end

  def applicable_suppliers
    object.applicable_suppliers_list
  end
end

