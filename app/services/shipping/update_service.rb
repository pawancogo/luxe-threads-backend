# frozen_string_literal: true

# Service for updating shipping methods
module Shipping
  class UpdateService < BaseService
    attr_reader :shipping_method

    def initialize(shipping_method, shipping_method_params)
      super()
      @shipping_method = shipping_method
      @shipping_method_params = shipping_method_params
    end

    def call
      with_transaction do
        update_shipping_method
      end
      set_result(@shipping_method)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_shipping_method
      unless @shipping_method.update(@shipping_method_params)
        add_errors(@shipping_method.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @shipping_method
      end
    end
  end
end

