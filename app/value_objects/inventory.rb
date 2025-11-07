# frozen_string_literal: true

# Value object for inventory calculations
# Encapsulates stock quantity logic
class Inventory
  attr_reader :stock_quantity, :reserved_quantity, :low_stock_threshold

  def initialize(stock_quantity:, reserved_quantity: 0, low_stock_threshold: 10)
    @stock_quantity = stock_quantity.to_i
    @reserved_quantity = reserved_quantity.to_i
    @low_stock_threshold = low_stock_threshold.to_i
  end

  # Available quantity (stock - reserved)
  def available_quantity
    [@stock_quantity - @reserved_quantity, 0].max
  end

  # Check if in stock
  def in_stock?
    available_quantity > 0
  end

  # Check if out of stock
  def out_of_stock?
    available_quantity <= 0
  end

  # Check if low stock
  def low_stock?
    available_quantity <= @low_stock_threshold && available_quantity > 0
  end

  # Check if can fulfill quantity
  def can_fulfill?(requested_quantity)
    available_quantity >= requested_quantity.to_i
  end

  # Get stock status
  def status
    return :out_of_stock if out_of_stock?
    return :low_stock if low_stock?
    :in_stock
  end

  # Get stock status message
  def status_message
    case status
    when :out_of_stock
      'Out of stock'
    when :low_stock
      "Only #{available_quantity} left"
    else
      'In stock'
    end
  end

  def ==(other)
    return false unless other.is_a?(Inventory)
    stock_quantity == other.stock_quantity &&
    reserved_quantity == other.reserved_quantity &&
    low_stock_threshold == other.low_stock_threshold
  end
end

