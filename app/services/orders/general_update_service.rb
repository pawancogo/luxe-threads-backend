# frozen_string_literal: true

# Service for updating order general information (non-status fields)
module Orders
  class GeneralUpdateService < BaseService
    attr_reader :order

    def initialize(order, order_params)
      super()
      @order = order
      @order_params = order_params.except(:status, :payment_status) # Status updates handled by Orders::StatusUpdateService
    end

    def call
      with_transaction do
        update_order
      end
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_order
      unless @order.update(@order_params)
        add_errors(@order.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @order
      end
    end
  end
end

