# frozen_string_literal: true

class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user
  belongs_to :order
  
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_amount, presence: true, numericality: { greater_than: 0 }
  
  # Increment coupon usage count
  after_create :increment_coupon_uses
  
  private
  
  def increment_coupon_uses
    coupon.increment!(:current_uses)
  end
end



