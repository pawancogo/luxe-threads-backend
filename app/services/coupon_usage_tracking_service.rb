# frozen_string_literal: true

# Service for tracking coupon usage and incrementing usage count
class CouponUsageTrackingService < BaseService
  attr_reader :coupon_usage

  def initialize(coupon_usage)
    super()
    @coupon_usage = coupon_usage
  end

  def call
    with_transaction do
      increment_coupon_uses
    end
    set_result(@coupon_usage)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def increment_coupon_uses
    @coupon_usage.coupon.increment!(:current_uses)
  end
end

