# frozen_string_literal: true

# Service for deleting cart items
module Carts
  class ItemDeletionService < BaseService
    attr_reader :cart_item

    def initialize(cart_item)
      super()
      @cart_item = cart_item
    end

    def call
      with_transaction do
        delete_cart_item
      end
      set_result(@cart_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_cart_item
      @cart_item.destroy
    end
  end
end

