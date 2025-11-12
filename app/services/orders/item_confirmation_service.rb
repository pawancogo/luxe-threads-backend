# frozen_string_literal: true

# Service for confirming order items
module Orders
  class ItemConfirmationService < BaseService
    attr_reader :order_item, :order

    def initialize(order_item)
      super()
      @order_item = order_item
      @order = order_item.order
    end

    def call
      validate_order_status!
      confirm_order_item
      sync_order_status
      set_result(@order_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_order_status!
      unless @order.status == 'pending' || @order.status == 'paid'
        add_error('Order cannot be confirmed in current status')
        raise StandardError, 'Invalid order status'
      end
    end

    def confirm_order_item
      @order_item.update!(fulfillment_status: 'processing')
    end

    def sync_order_status
      Orders::StatusSyncService.new(@order).call
    end
  end
end

