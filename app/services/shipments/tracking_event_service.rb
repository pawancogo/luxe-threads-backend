# frozen_string_literal: true

# Service for adding tracking events to shipments
module Shipments
  class TrackingEventService < BaseService
    attr_reader :tracking_event, :shipment

    def initialize(shipment, tracking_event_params)
      super()
      @shipment = shipment
      @tracking_event_params = tracking_event_params
    end

    def call
      create_tracking_event
      update_shipment_status
      set_result(@tracking_event)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_tracking_event
      @tracking_event = @shipment.shipment_tracking_events.build(@tracking_event_params)
      @tracking_event.event_time ||= Time.current
      
      unless @tracking_event.save
        add_errors(@tracking_event.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @tracking_event
      end
    end

    def update_shipment_status
      if ['delivered', 'failed', 'returned'].include?(@tracking_event.event_type)
        @shipment.update(status: @tracking_event.event_type)
      end
    end
  end
end

