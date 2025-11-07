# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  
  # Phase 4: Enhanced cart item features
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  # Update price_when_added on create
  before_create :set_price_when_added
  
  # Check if price changed
  def price_changed?
    return false unless price_when_added.present?
    product_variant.price != price_when_added
  end
  
  # Get current total
  def current_total
    (product_variant.price * quantity).round(2)
  end
  
  # Get total when added
  def total_when_added
    return 0 unless price_when_added.present?
    (price_when_added * quantity).round(2)
  end
  
  private
  
  def set_price_when_added
    self.price_when_added = product_variant.price
  end
end