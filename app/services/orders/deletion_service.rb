# frozen_string_literal: true

# Service for deleting orders
module Orders
  class DeletionService < BaseService
    attr_reader :order

    def initialize(order)
      super()
      @order = order
    end

    def call
      with_transaction do
        delete_order
      end
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_order
      @order.destroy
    end
  end
end

