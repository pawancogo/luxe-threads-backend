# frozen_string_literal: true

# Service for updating order item tracking information
module Orders
  class ItemTrackingUpdateService < BaseService
    attr_reader :order_item, :order

    def initialize(order_item, tracking_number, tracking_url: nil)
      super()
      @order_item = order_item
      @order = order_item.order
      @tracking_number = tracking_number
      @tracking_url = tracking_url
    end

    def call
      validate_tracking_number!
      validate_order_status!
      update_order_item_tracking
      update_order_tracking
      set_result(@order_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_tracking_number!
      unless @tracking_number.present?
        add_error('Tracking number is required')
        raise StandardError, 'Tracking number required'
      end
    end

    def validate_order_status!
      unless @order.status == 'shipped' || @order_item.fulfillment_status == 'shipped'
        add_error('Tracking can only be updated for shipped orders')
        raise StandardError, 'Invalid order status'
      end
    end

    def update_order_item_tracking
      @order_item.update!(
        tracking_number: @tracking_number,
        tracking_url: @tracking_url,
        updated_at: Time.current
      )
    end

    def update_order_tracking
      if @order.tracking_number != @tracking_number
        @order.update!(
          tracking_number: @tracking_number,
          tracking_url: @tracking_url,
          updated_at: Time.current
        )
      end
    end
  end
end

