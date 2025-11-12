# frozen_string_literal: true

class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :product_variant
  
  # Phase 4: Enhanced wishlist item features
  validates :wishlist_id, uniqueness: { scope: :product_variant_id, message: "is already in this wishlist" }
  validates :priority, numericality: { greater_than_or_equal_to: 0 }
  
  scope :by_priority, -> { order(priority: :desc, created_at: :desc) }
  scope :price_dropped, -> { where('current_price < price_when_added') }
  
  # Update current price
  before_save :update_current_price
  
  # Check if price dropped
  def price_dropped?
    return false unless price_when_added.present? && current_price.present?
    current_price < price_when_added
  end
  
  # Note: notify_price_drop! method removed - use WishlistItemPriceDropNotificationService instead
  
  private
  
  def update_current_price
    self.current_price = product_variant.price if product_variant.present?
  end
end
