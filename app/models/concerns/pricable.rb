# frozen_string_literal: true

# Concern for models that have pricing
# Provides price value object integration
module Pricable
  extend ActiveSupport::Concern

  # Get price value object
  def price_object
    Price.new(
      base_price || price || 0,
      discounted_price: discounted_price,
      currency: currency || 'INR'
    )
  end

  # Get current price (discounted if available)
  def current_price
    price_object.final
  end

  # Check if discounted
  def discounted?
    price_object.discounted?
  end

  # Get discount amount
  def discount_amount
    price_object.discount_amount
  end

  # Get discount percentage
  def discount_percentage
    price_object.discount_percentage
  end

  # Format price for display
  def formatted_price
    price_object.formatted
  end
end

