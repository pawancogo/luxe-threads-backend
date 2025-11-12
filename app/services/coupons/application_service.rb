# frozen_string_literal: true

# Service for applying coupons
module Coupons
  class ApplicationService < BaseService
    attr_reader :coupon, :discount_amount, :final_amount

    def initialize(code, order_amount, user)
      super()
      @code = code&.strip&.upcase
      @order_amount = order_amount.to_f
      @user = user
    end

    def call
      validate_order_amount!
      validate_coupon
      calculate_discount
      set_result({
        coupon: @coupon,
        discount_amount: @discount_amount,
        final_amount: @final_amount
      })
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

    def validate_coupon
      validation_service = ValidationService.new(@code, user: @user)
      validation_service.call
      
      unless validation_service.success?
        add_errors(validation_service.errors)
        raise StandardError, 'Coupon validation failed'
      end
      
      @coupon = validation_service.coupon
    end

    def calculate_discount
      # Validate minimum order amount
      if @coupon.min_order_amount.present? && @order_amount < @coupon.min_order_amount
        add_error("Minimum order amount is ₹#{@coupon.min_order_amount}")
        raise StandardError, 'Minimum order amount not met'
      end
      
      # Calculate discount using service
      discount_service = DiscountCalculationService.new(@coupon, @order_amount)
      discount_service.call
      
      unless discount_service.success?
        add_errors(discount_service.errors)
        raise StandardError, 'Failed to calculate discount'
      end
      
      @discount_amount = discount_service.discount_amount.to_f
      @final_amount = @order_amount - @discount_amount
    end
  end
end

