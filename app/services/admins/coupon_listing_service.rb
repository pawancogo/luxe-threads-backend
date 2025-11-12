# frozen_string_literal: true

# Service for building admin coupon listing queries
# Extracts query building logic from controllers
module Admins
  class CouponListingService < BaseService
    attr_reader :coupons

    def initialize(params = {})
      super()
      @params = params
    end

    def call
      build_query
      apply_filters
      apply_ordering
      set_result(@coupons)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @coupons = Coupon.all
    end

    def apply_filters
      @coupons = @coupons.where(is_active: @params[:is_active] == 'true') if @params[:is_active].present?
      @coupons = @coupons.where(coupon_type: @params[:coupon_type]) if @params[:coupon_type].present?
    end

    def apply_ordering
      @coupons = @coupons.order(created_at: :desc)
    end
  end
end

