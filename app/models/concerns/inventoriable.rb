# frozen_string_literal: true

# Concern for models that have inventory
# Provides inventory value object integration
module Inventoriable
  extend ActiveSupport::Concern

  # Get inventory value object
  def inventory_object
    Inventory.new(
      stock_quantity: stock_quantity || 0,
      reserved_quantity: reserved_quantity || 0,
      low_stock_threshold: low_stock_threshold || 10
    )
  end

  # Available quantity
  def available_quantity
    inventory_object.available_quantity
  end

  # Check if in stock
  def in_stock?
    inventory_object.in_stock?
  end

  # Check if out of stock
  def out_of_stock?
    inventory_object.out_of_stock?
  end

  # Check if low stock
  def low_stock?
    inventory_object.low_stock?
  end

  # Check if can fulfill quantity
  def can_fulfill?(requested_quantity)
    inventory_object.can_fulfill?(requested_quantity)
  end

  # Get stock status
  def stock_status
    inventory_object.status
  end

  # Get stock status message
  def stock_status_message
    inventory_object.status_message
  end
end

