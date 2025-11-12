# frozen_string_literal: true

# Service for synchronizing order status based on order items fulfillment status
module Orders
  class StatusSyncService < BaseService
    attr_reader :order

    def initialize(order)
      super()
      @order = order
    end

    def call
      sync_order_status
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def sync_order_status
      all_items_processing = all_items_processing?
      all_items_packed = all_items_packed?

      if all_items_packed && @order.status == 'paid'
        @order.update!(status: 'packed')
      elsif all_items_processing && @order.status == 'pending' && @order.payment_status == 'payment_complete'
        @order.update!(status: 'paid') if @order.status == 'pending'
      end
    end

    def all_items_processing?
      @order.order_items.all? do |item|
        ['processing', 'packed', 'shipped', 'delivered'].include?(item.fulfillment_status)
      end
    end

    def all_items_packed?
      @order.order_items.all? do |item|
        ['packed', 'shipped', 'delivered'].include?(item.fulfillment_status)
      end
    end
  end
end

