# frozen_string_literal: true

# Value object for discount calculations
# Encapsulates discount logic from coupons and promotions
class Discount
  attr_reader :type, :value, :currency

  DISCOUNT_TYPES = {
    percentage: 'percentage',
    fixed_amount: 'fixed_amount',
    free_shipping: 'free_shipping'
  }.freeze

  def initialize(type:, value:, currency: 'INR')
    @type = type.to_s
    @value = BigDecimal(value.to_s)
    @currency = currency.to_s.upcase
    validate!
  end

  # Calculate discount amount for given order amount
  def calculate(order_amount)
    case @type
    when DISCOUNT_TYPES[:percentage]
      (order_amount * @value / 100).round(2)
    when DISCOUNT_TYPES[:fixed_amount]
      [@value, order_amount].min # Can't discount more than order amount
    when DISCOUNT_TYPES[:free_shipping]
      BigDecimal('0') # Free shipping is handled separately
    else
      BigDecimal('0')
    end
  end

  # Get formatted discount description
  def description
    case @type
    when DISCOUNT_TYPES[:percentage]
      "#{@value.to_f}% off"
    when DISCOUNT_TYPES[:fixed_amount]
      "₹#{@value.to_f} off"
    when DISCOUNT_TYPES[:free_shipping]
      "Free shipping"
    else
      "Discount"
    end
  end

  def percentage?
    @type == DISCOUNT_TYPES[:percentage]
  end

  def fixed_amount?
    @type == DISCOUNT_TYPES[:fixed_amount]
  end

  def free_shipping?
    @type == DISCOUNT_TYPES[:free_shipping]
  end

  private

  def validate!
    unless DISCOUNT_TYPES.values.include?(@type)
      raise ArgumentError, "Invalid discount type: #{@type}"
    end

    if @value < 0
      raise ArgumentError, "Discount value cannot be negative"
    end

    if percentage? && @value > 100
      raise ArgumentError, "Percentage discount cannot exceed 100%"
    end
  end
end

