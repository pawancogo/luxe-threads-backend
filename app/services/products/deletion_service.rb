# frozen_string_literal: true

# Service for deleting products
module Products
  class DeletionService < BaseService
    attr_reader :product

    def initialize(product)
      super()
      @product = product
    end

    def call
      with_transaction do
        delete_product
      end
      set_result(@product)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_product
      @product.destroy
    end
  end
end

