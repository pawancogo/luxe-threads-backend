# frozen_string_literal: true

# Service for calculating discount amount for a coupon
# Extracted from Coupon model to follow SOLID principles
module Coupons
  class DiscountCalculationService < BaseService
    attr_reader :discount_amount

    def initialize(coupon, order_amount)
      super()
      @coupon = coupon
      @order_amount = order_amount.to_f
    end

    def call
      validate_order_amount!
      calculate_discount
      apply_max_discount_limit
      set_result(@discount_amount)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_order_amount!
      if @order_amount <= 0
        add_error('Order amount must be greater than 0')
        raise StandardError, 'Invalid order amount'
      end
    end

    def calculate_discount
      discount_object = @coupon.discount_object
      @discount_amount = discount_object.calculate(BigDecimal(@order_amount.to_s))
    end

    def apply_max_discount_limit
      if @coupon.max_discount_amount.present? && @discount_amount > @coupon.max_discount_amount
        @discount_amount = @coupon.max_discount_amount
      end
    end
  end
end

