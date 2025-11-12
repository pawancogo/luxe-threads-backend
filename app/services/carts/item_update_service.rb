# frozen_string_literal: true

# Service for updating cart item quantity
module Carts
  class ItemUpdateService < BaseService
    attr_reader :cart_item

    def initialize(cart_item, quantity)
      super()
      @cart_item = cart_item
      @quantity = quantity.to_i
    end

    def call
      validate!
      update_quantity
      set_result(@cart_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      if @quantity <= 0
        add_error('Quantity must be greater than 0')
        raise StandardError, 'Invalid quantity'
      end
    end

    def update_quantity
      unless @cart_item.update(quantity: @quantity)
        add_errors(@cart_item.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @cart_item
      end
    end
  end
end

