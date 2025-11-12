# frozen_string_literal: true

# Service for updating coupons
module Coupons
  class UpdateService < BaseService
    attr_reader :coupon

    def initialize(coupon, coupon_params)
      super()
      @coupon = coupon
      @coupon_params = coupon_params
    end

    def call
      with_transaction do
        update_coupon
      end
      set_result(@coupon)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_coupon
      update_hash = {}
      update_hash[:code] = @coupon_params[:code]&.upcase if @coupon_params.key?(:code)
      update_hash[:name] = @coupon_params[:name] if @coupon_params.key?(:name)
      update_hash[:description] = @coupon_params[:description] if @coupon_params.key?(:description)
      update_hash[:coupon_type] = @coupon_params[:coupon_type] if @coupon_params.key?(:coupon_type)
      update_hash[:discount_value] = @coupon_params[:discount_value] if @coupon_params.key?(:discount_value)
      update_hash[:max_discount_amount] = @coupon_params[:max_discount_amount] if @coupon_params.key?(:max_discount_amount)
      update_hash[:min_order_amount] = @coupon_params[:min_order_amount] if @coupon_params.key?(:min_order_amount)
      update_hash[:valid_from] = @coupon_params[:valid_from] if @coupon_params.key?(:valid_from)
      update_hash[:valid_until] = @coupon_params[:valid_until] if @coupon_params.key?(:valid_until)
      update_hash[:is_active] = @coupon_params[:is_active] if @coupon_params.key?(:is_active)
      update_hash[:max_uses] = @coupon_params[:max_uses] if @coupon_params.key?(:max_uses)
      update_hash[:max_uses_per_user] = @coupon_params[:max_uses_per_user] if @coupon_params.key?(:max_uses_per_user)
      update_hash[:is_new_user_only] = @coupon_params[:is_new_user_only] if @coupon_params.key?(:is_new_user_only)
      update_hash[:is_first_order_only] = @coupon_params[:is_first_order_only] if @coupon_params.key?(:is_first_order_only)
      update_hash[:applicable_categories] = @coupon_params[:applicable_categories]&.to_json if @coupon_params.key?(:applicable_categories)
      update_hash[:applicable_products] = @coupon_params[:applicable_products]&.to_json if @coupon_params.key?(:applicable_products)
      update_hash[:applicable_brands] = @coupon_params[:applicable_brands]&.to_json if @coupon_params.key?(:applicable_brands)
      update_hash[:applicable_suppliers] = @coupon_params[:applicable_suppliers]&.to_json if @coupon_params.key?(:applicable_suppliers)
      
      unless @coupon.update(update_hash)
        add_errors(@coupon.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @coupon
      end
    end
  end
end

