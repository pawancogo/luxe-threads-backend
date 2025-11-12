# frozen_string_literal: true

# Service for creating shipments
module Shipments
  class CreationService < BaseService
    attr_reader :shipment

    def initialize(order_item, shipment_params)
      super()
      @order_item = order_item
      @shipment_params = shipment_params
    end

    def call
      create_shipment
      set_result(@shipment)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_shipment
      @shipment = @order_item.shipments.build(@shipment_params)
      @shipment.order = @order_item.order
      @shipment.status = 'pending'
      
      unless @shipment.save
        add_errors(@shipment.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @shipment
      end
    end
  end
end

