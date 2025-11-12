# frozen_string_literal: true

# Service for shipping order items
module Orders
  class ItemShipmentService < BaseService
    attr_reader :order_item, :order

    def initialize(order_item, tracking_number)
      super()
      @order_item = order_item
      @order = order_item.order
      @tracking_number = tracking_number
    end

    def call
      validate_tracking_number!
      ship_order_item
      update_order_status
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

    def ship_order_item
      if @order_item.respond_to?(:fulfillment_status)
        # Use update! to trigger validations and callbacks
        unless @order_item.update!(
          fulfillment_status: 'shipped',
          shipped_at: Time.current,
          tracking_number: @tracking_number
        )
          add_errors(@order_item.errors.full_messages)
          raise ActiveRecord::RecordInvalid, @order_item
        end
      end
    end

    def update_order_status
      if @order.status == 'paid' || @order.status == 'packed'
        # Use update! to trigger validations and callbacks (including status change callbacks)
        unless @order.update!(
          status: 'shipped',
          tracking_number: @tracking_number
        )
          add_errors(@order.errors.full_messages)
          raise ActiveRecord::RecordInvalid, @order
        end
      end
    end
  end
end

