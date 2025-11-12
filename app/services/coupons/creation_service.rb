# frozen_string_literal: true

# Service for creating coupons
module Coupons
  class CreationService < BaseService
    attr_reader :coupon

    def initialize(coupon_params)
      super()
      @coupon_params = coupon_params
    end

    def call
      with_transaction do
        create_coupon
      end
      set_result(@coupon)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_coupon
      @coupon = Coupon.new(
        code: @coupon_params[:code]&.upcase,
        name: @coupon_params[:name],
        description: @coupon_params[:description],
        coupon_type: @coupon_params[:coupon_type],
        discount_value: @coupon_params[:discount_value],
        max_discount_amount: @coupon_params[:max_discount_amount],
        min_order_amount: @coupon_params[:min_order_amount] || 0,
        valid_from: @coupon_params[:valid_from],
        valid_until: @coupon_params[:valid_until],
        is_active: @coupon_params[:is_active] != false,
        max_uses: @coupon_params[:max_uses],
        max_uses_per_user: @coupon_params[:max_uses_per_user],
        is_new_user_only: @coupon_params[:is_new_user_only] || false,
        is_first_order_only: @coupon_params[:is_first_order_only] || false,
        applicable_categories: @coupon_params[:applicable_categories]&.to_json,
        applicable_products: @coupon_params[:applicable_products]&.to_json,
        applicable_brands: @coupon_params[:applicable_brands]&.to_json,
        applicable_suppliers: @coupon_params[:applicable_suppliers]&.to_json
      )
      
      unless @coupon.save
        add_errors(@coupon.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @coupon
      end
    end
  end
end

