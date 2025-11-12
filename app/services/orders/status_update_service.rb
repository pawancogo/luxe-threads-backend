# frozen_string_literal: true

# Service for updating order status
# Handles status updates, history tracking, and email notifications
module Orders
  class StatusUpdateService < BaseService
    attr_reader :order

    def initialize(order, new_status, updated_by: nil, notes: nil)
      super()
      @order = order
      @new_status = new_status.to_s
      @updated_by = updated_by
      @notes = notes
    end

    def call
      validate_status!
      update_status
      update_status_history
      send_status_notification
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_status!
      valid_statuses = Order.statuses.keys
      unless valid_statuses.include?(@new_status)
        add_error("Invalid status: #{@new_status}")
        raise StandardError, "Invalid status: #{@new_status}"
      end

      # Validate status transition (basic validation)
      if @order.status == @new_status
        add_error("Order is already #{@new_status}")
        raise StandardError, "Order is already #{@new_status}"
      end
    end

    def update_status
      @order.update!(status: @new_status)
    end

    def update_status_history
      notes = @notes || "Status updated to #{@new_status}"
      notes += " by #{@updated_by}" if @updated_by.present?
      @order.add_status_to_history(@new_status, notes: notes)
    end

    def send_status_notification
      Orders::EmailService.send_status_notification(@order)
    end
  end
end

