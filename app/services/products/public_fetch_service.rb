# frozen_string_literal: true

# Service for fetching public product data with proper eager loading
# Extracts product fetching logic from controllers
module Products
  class PublicFetchService < BaseService
    attr_reader :product

    def initialize(identifier)
      super()
      @identifier = identifier
    end

    def call
      fetch_product
      set_result(@product)
      self
    rescue ActiveRecord::RecordNotFound => e
      handle_error(e)
      self
    end

    private

    def fetch_product
      base_scope = Product.active.with_full_details
      
      # Try slug first, then ID
      @product = base_scope.find_by(slug: @identifier) || base_scope.find(@identifier)
    end
  end
end

