# frozen_string_literal: true

# Service for validating coupons
module Coupons
  class ValidationService < BaseService
    attr_reader :coupon

    def initialize(code, user: nil)
      super()
      @code = code&.strip&.upcase
      @user = user
    end

    def call
      validate_code!
      find_coupon
      validate_availability!
      validate_user! if @user
      set_result(@coupon)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_code!
      if @code.blank?
        add_error('Coupon code is required')
        raise StandardError, 'Coupon code is required'
      end
    end

    def find_coupon
      @coupon = Coupon.find_by(code: @code)
      unless @coupon
        add_error('Coupon not found')
        raise StandardError, 'Invalid coupon code'
      end
    end

    def validate_availability!
      unless @coupon.available?
        add_error('Coupon is not available')
        raise StandardError, 'Coupon expired or inactive'
      end
    end

    def validate_user!
      user_validation = UserValidationService.new(@coupon, @user)
      user_validation.call
      
      unless user_validation.success?
        add_errors(user_validation.errors)
        raise StandardError, 'User restrictions apply'
      end
    end
  end
end

