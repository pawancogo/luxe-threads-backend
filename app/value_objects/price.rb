# frozen_string_literal: true

# Value object for price calculations
# Encapsulates price logic (base price, discounted price, final price)
class Price
  attr_reader :base_price, :discounted_price, :currency

  def initialize(base_price, discounted_price: nil, currency: 'INR')
    @base_price = BigDecimal(base_price.to_s)
    @discounted_price = discounted_price ? BigDecimal(discounted_price.to_s) : nil
    @currency = currency.to_s.upcase
  end

  # Get final price (discounted if available, otherwise base)
  def final
    @discounted_price || @base_price
  end

  # Check if price is discounted
  def discounted?
    @discounted_price.present? && @discounted_price < @base_price
  end

  # Get discount amount
  def discount_amount
    return BigDecimal('0') unless discounted?
    @base_price - @discounted_price
  end

  # Get discount percentage
  def discount_percentage
    return 0 unless discounted?
    ((discount_amount / @base_price) * 100).round(2)
  end

  # Calculate total for quantity
  def total(quantity = 1)
    final * quantity
  end

  # Format price for display
  def formatted
    "₹#{final.to_f.round(2)}"
  end

  # Format with original price if discounted
  def formatted_with_original
    if discounted?
      "₹#{final.to_f.round(2)} <span class='line-through text-gray-500'>₹#{@base_price.to_f.round(2)}</span>"
    else
      formatted
    end
  end

  def to_f
    final.to_f
  end

  def to_d
    final
  end

  def ==(other)
    return false unless other.is_a?(Price)
    base_price == other.base_price && 
    discounted_price == other.discounted_price && 
    currency == other.currency
  end
end

