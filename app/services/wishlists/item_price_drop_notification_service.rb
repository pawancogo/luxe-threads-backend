# frozen_string_literal: true

# Service for notifying users about price drops on wishlist items
module Wishlists
  class ItemPriceDropNotificationService < BaseService
    attr_reader :wishlist_item

    def initialize(wishlist_item)
      super()
      @wishlist_item = wishlist_item
    end

    def call
      return self if @wishlist_item.price_drop_notified?
      return self unless @wishlist_item.price_dropped?

      with_transaction do
        notify_price_drop
      end
      set_result(@wishlist_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def notify_price_drop
      # TODO: Send notification via NotificationService
      # NotificationService.new(@wishlist_item.wishlist.user).notify_price_drop(@wishlist_item)
      
      unless @wishlist_item.update(price_drop_notified: true)
        add_errors(@wishlist_item.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @wishlist_item
      end
    end
  end
end

