# frozen_string_literal: true

# Service for deleting shipping methods
module Shipping
  class DeletionService < BaseService
    attr_reader :shipping_method

    def initialize(shipping_method)
      super()
      @shipping_method = shipping_method
    end

    def call
      with_transaction do
        delete_shipping_method
      end
      set_result(@shipping_method)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_shipping_method
      @shipping_method.destroy
    end
  end
end

