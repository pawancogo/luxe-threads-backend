# frozen_string_literal: true

# Service for updating product variant availability flags
# Extracted from ProductVariant model callbacks to follow SOLID principles
module Products
  class VariantAvailabilityService < BaseService
    def initialize(variant)
      super()
      @variant = variant
    end

    def call
      update_availability_flags
      # Save variant if it has changes (when called directly, not from callback)
      @variant.save! if @variant.changed? && !@variant.new_record?
      update_product_metrics
      set_result(@variant)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_availability_flags
      available_quantity = (@variant.stock_quantity || 0) - (@variant.reserved_quantity || 0)
      low_stock_threshold = @variant.low_stock_threshold || 10

      @variant.available_quantity = available_quantity
      @variant.is_low_stock = available_quantity <= low_stock_threshold
      @variant.out_of_stock = available_quantity <= 0
      @variant.is_available = available_quantity > 0
    end

    def update_product_metrics
      return unless @variant.product.present?
      @variant.product.update_inventory_metrics if @variant.product.respond_to?(:update_inventory_metrics)
    end
  end
end

