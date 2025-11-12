# frozen_string_literal: true

# Service for validating if a coupon is applicable to a specific order
# Extracted from Coupon model to follow SOLID principles
module Coupons
  class OrderValidationService < BaseService
    def initialize(coupon, order)
      super()
      @coupon = coupon
      @order = order
    end

    def call
      validate_user!
      validate_minimum_amount!
      validate_applicable_items!
      validate_excluded_items!
      set_result(true)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    def applicable?
      success?
    end

    private

    def validate_user!
      user_validation = UserValidationService.new(@coupon, @order.user)
      user_validation.call

      unless user_validation.success?
        add_errors(user_validation.errors)
        raise StandardError, 'Coupon not valid for user'
      end
    end

    def validate_minimum_amount!
      if @coupon.min_order_amount.present? && @order.total_amount < @coupon.min_order_amount
        add_error("Minimum order amount is ₹#{@coupon.min_order_amount}")
        raise StandardError, 'Minimum order amount not met'
      end
    end

    def validate_applicable_items!
      order_items = @order.order_items
      applicable = false

      applicable_categories = @coupon.applicable_categories_list
      if applicable_categories.present?
        applicable ||= order_items.joins(product: :category)
                                  .where(categories: { id: applicable_categories })
                                  .exists?
      end

      applicable_products = @coupon.applicable_products_list
      if applicable_products.present?
        applicable ||= order_items.where(product_id: applicable_products).exists?
      end

      applicable_brands = @coupon.applicable_brands_list
      if applicable_brands.present?
        applicable ||= order_items.joins(product: :brand)
                                  .where(brands: { id: applicable_brands })
                                  .exists?
      end

      # If no restrictions specified, coupon is applicable
      if applicable_categories.blank? && applicable_products.blank? && applicable_brands.blank?
        applicable = true
      end

      unless applicable
        add_error('Coupon not applicable to order items')
        raise StandardError, 'No matching items in order'
      end
    end

    def validate_excluded_items!
      order_items = @order.order_items

      exclude_categories = @coupon.exclude_categories_list
      if exclude_categories.present?
        if order_items.joins(product: :category)
                      .where(categories: { id: exclude_categories })
                      .exists?
          add_error('Order contains excluded categories')
          raise StandardError, 'Excluded categories in order'
        end
      end

      exclude_products = @coupon.exclude_products_list
      if exclude_products.present?
        if order_items.where(product_id: exclude_products).exists?
          add_error('Order contains excluded products')
          raise StandardError, 'Excluded products in order'
        end
      end
    end
  end
end

