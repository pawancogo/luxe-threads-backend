# frozen_string_literal: true

# Service for creating shipping methods
module Shipping
  class CreationService < BaseService
    attr_reader :shipping_method

    def initialize(shipping_method_params)
      super()
      @shipping_method_params = shipping_method_params
    end

    def call
      with_transaction do
        create_shipping_method
      end
      set_result(@shipping_method)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_shipping_method
      @shipping_method = ShippingMethod.new(@shipping_method_params)
      
      unless @shipping_method.save
        add_errors(@shipping_method.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @shipping_method
      end
    end
  end
end

