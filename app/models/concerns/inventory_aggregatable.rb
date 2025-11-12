# frozen_string_literal: true

# Concern for models that aggregate inventory metrics from associated records
# Used by Product to aggregate inventory from ProductVariant
module InventoryAggregatable
  extend ActiveSupport::Concern

  included do
    # Override in including class to specify association name
    # Example: inventory_aggregatable_on :product_variants
  end

  class_methods do
    def inventory_aggregatable_on(association_name, metrics: {
      total_stock: :stock_quantity,
      low_stock_count: { scope: ->(variants) { variants.where(is_low_stock: true) }, count: true }
    })
      @inventory_association = association_name
      @inventory_metrics = metrics
    end

    def inventory_association
      @inventory_association || :variants
    end

    def inventory_metrics
      @inventory_metrics || {}
    end
  end

  # Update aggregated inventory metrics from associated records
  def update_inventory_metrics
    association_name = self.class.inventory_association
    return unless respond_to?(association_name)

    variants = public_send(association_name)
    metrics = self.class.inventory_metrics

    metrics.each do |metric_name, config|
      if config.is_a?(Hash) && config[:scope]
        # Custom scope-based metric
        scoped_variants = config[:scope].call(variants)
        value = config[:count] ? scoped_variants.count : scoped_variants.sum(config[:sum_column] || :id)
      elsif config.is_a?(Symbol)
        # Simple sum aggregation
        value = variants.sum(config)
      else
        # Default: sum stock_quantity
        value = variants.sum(:stock_quantity) || 0
      end

      # Set the metric attribute
      attribute_name = metric_name.to_s
      if respond_to?("#{attribute_name}=")
        public_send("#{attribute_name}=", value)
      end
    end

    # Default metrics if not configured
    if respond_to?(:total_stock_quantity=) && !metrics.key?(:total_stock)
      self.total_stock_quantity = variants.sum(:stock_quantity) || 0
    end

    if respond_to?(:low_stock_variants_count=) && !metrics.key?(:low_stock_count)
      self.low_stock_variants_count = variants.where(is_low_stock: true).count
    end

    save if changed?
  end

  # Check if product is available (has stock)
  def available?
    return false unless respond_to?(:total_stock_quantity)
    total_stock_quantity.to_i > 0
  end
end


