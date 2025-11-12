# frozen_string_literal: true

# Service for validating if a coupon is valid for a specific user
# Extracted from Coupon model to follow SOLID principles
module Coupons
  class UserValidationService < BaseService
    def initialize(coupon, user)
      super()
      @coupon = coupon
      @user = user
    end

    def call
      validate_availability!
      validate_user_restrictions!
      validate_usage_limits!
      set_result(true)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    def valid?
      success?
    end

    private

    def validate_availability!
      unless @coupon.available?
        add_error('Coupon is not available')
        raise StandardError, 'Coupon expired or inactive'
      end
    end

    def validate_user_restrictions!
      return unless @user

      if @coupon.new_users_only? && @user.created_at > @coupon.valid_from
        add_error('Coupon is only valid for new users')
        raise StandardError, 'User restriction: new users only'
      end

      if @coupon.first_order_only? && @user.orders.exists?
        add_error('Coupon is only valid for first order')
        raise StandardError, 'User restriction: first order only'
      end

      applicable_user_ids = @coupon.applicable_user_ids_list
      if applicable_user_ids.present? && !applicable_user_ids.include?(@user.id)
        add_error('Coupon not valid for this user')
        raise StandardError, 'User not in applicable list'
      end

      exclude_user_ids = @coupon.exclude_user_ids_list
      if exclude_user_ids.present? && exclude_user_ids.include?(@user.id)
        add_error('Coupon not valid for this user')
        raise StandardError, 'User in exclusion list'
      end
    end

    def validate_usage_limits!
      return unless @user

      if @coupon.max_uses_per_user.present?
        usage_count = @coupon.coupon_usages.where(user: @user).count
        if usage_count >= @coupon.max_uses_per_user
          add_error('Coupon usage limit reached for this user')
          raise StandardError, 'Usage limit exceeded'
        end
      end
    end
  end
end

