# frozen_string_literal: true

# Concern for models that aggregate prices from associated records
# Used by Product to aggregate prices from ProductVariant
module PriceAggregatable
  extend ActiveSupport::Concern

  included do
    # Override in including class to specify association name
    # Example: price_aggregatable_on :product_variants
  end

  class_methods do
    def price_aggregatable_on(association_name, price_columns: [:price, :discounted_price, :mrp])
      @price_association = association_name
      @price_columns = price_columns
    end

    def price_association
      @price_association || :variants
    end

    def price_columns
      @price_columns || [:price, :discounted_price, :mrp]
    end
  end

  # Update aggregated prices from associated records
  def update_aggregated_prices
    association_name = self.class.price_association
    return unless respond_to?(association_name)

    variants = public_send(association_name)
    return unless variants.any?

    price_columns = self.class.price_columns

    price_columns.each do |column|
      values = variants.pluck(column).compact
      next if values.empty?

      base_column = "base_#{column}"
      if respond_to?("#{base_column}=")
        case column
        when :price, :discounted_price
          public_send("#{base_column}=", values.min)
        when :mrp
          public_send("#{base_column}=", values.max)
        end
      end
    end
  end

  # Get current price (lowest discounted or regular price)
  def current_price
    return base_discounted_price if respond_to?(:base_discounted_price) && base_discounted_price.present?
    return base_price if respond_to?(:base_price) && base_price.present?

    # Fallback to variants if base prices not set
    association_name = self.class.price_association
    return nil unless respond_to?(association_name)

    variants = public_send(association_name)
    return nil unless variants.any?

    discounted = variants.minimum(:discounted_price)
    regular = variants.minimum(:price)
    discounted || regular
  end
end


