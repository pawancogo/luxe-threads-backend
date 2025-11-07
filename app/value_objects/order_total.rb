# frozen_string_literal: true

# Value object for order total calculations
# Encapsulates all order pricing logic
class OrderTotal
  attr_reader :subtotal, :shipping_cost, :tax_amount, :discount_amount, :currency

  def initialize(subtotal:, shipping_cost: 0, tax_amount: 0, discount_amount: 0, currency: 'INR')
    @subtotal = BigDecimal(subtotal.to_s)
    @shipping_cost = BigDecimal(shipping_cost.to_s)
    @tax_amount = BigDecimal(tax_amount.to_s)
    @discount_amount = BigDecimal(discount_amount.to_s)
    @currency = currency.to_s.upcase
  end

  # Calculate final total
  def total
    @subtotal + @shipping_cost + @tax_amount - @discount_amount
  end

  # Check if order has discount
  def has_discount?
    @discount_amount > 0
  end

  # Check if order has free shipping
  def has_free_shipping?
    @shipping_cost.zero?
  end

  # Get formatted breakdown
  def breakdown
    {
      subtotal: @subtotal.to_f,
      shipping: @shipping_cost.to_f,
      tax: @tax_amount.to_f,
      discount: @discount_amount.to_f,
      total: total.to_f,
      currency: @currency
    }
  end

  # Format total for display
  def formatted
    "₹#{total.to_f.round(2)}"
  end

  def to_f
    total.to_f
  end

  def to_d
    total
  end

  def ==(other)
    return false unless other.is_a?(OrderTotal)
    subtotal == other.subtotal &&
    shipping_cost == other.shipping_cost &&
    tax_amount == other.tax_amount &&
    discount_amount == other.discount_amount &&
    currency == other.currency
  end
end

