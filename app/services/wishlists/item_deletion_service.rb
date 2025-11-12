# frozen_string_literal: true

# Service for removing items from wishlist
module Wishlists
  class ItemDeletionService < BaseService
    attr_reader :wishlist_item

    def initialize(wishlist_item)
      super()
      @wishlist_item = wishlist_item
    end

    def call
      with_transaction do
        delete_wishlist_item
      end
      set_result(true)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_wishlist_item
      @wishlist_item.destroy
    end
  end
end

