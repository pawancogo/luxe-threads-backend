# frozen_string_literal: true

# Service for adding items to cart
module Carts
  class ItemCreationService < BaseService
    attr_reader :cart_item, :cart

    def initialize(cart, product_variant_id, quantity)
      super()
      @cart = cart
      @product_variant_id = product_variant_id
      @quantity = quantity.to_i
    end

    def call
      validate!
      find_or_create_cart_item
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

      variant = ProductVariant.find_by(id: @product_variant_id)
      unless variant
        add_error('Product variant not found')
        raise StandardError, 'Product variant not found'
      end

      unless variant.available?
        add_error('Product variant is not available')
        raise StandardError, 'Product variant not available'
      end
    end

    def find_or_create_cart_item
      @cart_item = @cart.cart_items.find_or_initialize_by(
        product_variant_id: @product_variant_id
      )
    end

    def update_quantity
      @cart_item.quantity = (@cart_item.quantity || 0) + @quantity
      
      unless @cart_item.save
        add_errors(@cart_item.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @cart_item
      end
    end
  end
end

