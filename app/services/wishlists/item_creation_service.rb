# frozen_string_literal: true

# Service for adding items to wishlist
module Wishlists
  class ItemCreationService < BaseService
    attr_reader :wishlist_item

    def initialize(wishlist, product_variant_id)
      super()
      @wishlist = wishlist
      @product_variant_id = product_variant_id
    end

    def call
      validate!
      find_or_create_wishlist_item
      set_result(@wishlist_item)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      variant = ProductVariant.find_by(id: @product_variant_id)
      unless variant
        add_error('Product variant not found')
        raise StandardError, 'Product variant not found'
      end
    end

    def find_or_create_wishlist_item
      @wishlist_item = @wishlist.wishlist_items.find_or_initialize_by(
        product_variant_id: @product_variant_id
      )
      
      if @wishlist_item.persisted?
        # Item already exists
        return
      end
      
      unless @wishlist_item.save
        add_errors(@wishlist_item.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @wishlist_item
      end
    end
  end
end

