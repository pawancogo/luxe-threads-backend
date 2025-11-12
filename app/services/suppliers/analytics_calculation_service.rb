# frozen_string_literal: true

# Service for calculating supplier analytics conversion rate
# Extracted from SupplierAnalytic model to follow SOLID principles
module Suppliers
  class AnalyticsCalculationService < BaseService
    attr_reader :conversion_rate

    def initialize(products_viewed, products_added_to_cart)
      super()
      @products_viewed = products_viewed.to_i
      @products_added_to_cart = products_added_to_cart.to_i
    end

    def call
      calculate_conversion_rate
      set_result(@conversion_rate)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def calculate_conversion_rate
      if @products_viewed.zero?
        @conversion_rate = 0.0
      else
        @conversion_rate = ((@products_added_to_cart.to_f / @products_viewed) * 100).round(2)
      end
    end
  end
end

