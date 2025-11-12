# frozen_string_literal: true

class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user
  belongs_to :order
  
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_amount, presence: true, numericality: { greater_than: 0 }
  
  # Note: Callback removed - use CouponUsageTrackingService instead
  # Call the service after creating coupon usage records
end



