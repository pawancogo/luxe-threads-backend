# frozen_string_literal: true

# Service for formatting supplier orders data
class SupplierOrdersFormattingService < BaseService
  attr_reader :formatted_orders

  def initialize(order_items)
    super()
    @order_items = order_items
  end

  def call
    format_orders
    set_result(@formatted_orders)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def format_orders
    @formatted_orders = @order_items.group_by(&:order).map do |order, items|
      {
        order: order,
        items: items
      }
    end
  end
end

