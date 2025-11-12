# frozen_string_literal: true

# Service for deleting coupons
module Coupons
  class DeletionService < BaseService
    attr_reader :coupon

    def initialize(coupon)
      super()
      @coupon = coupon
    end

    def call
      with_transaction do
        delete_coupon
      end
      set_result(@coupon)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_coupon
      @coupon.destroy
    end
  end
end

