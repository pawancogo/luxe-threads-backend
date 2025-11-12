# frozen_string_literal: true

# Service for cancelling orders
# Handles order cancellation, inventory restoration, status tracking, and email notifications
module Orders
  class CancellationService < BaseService
    attr_reader :order

    def initialize(order, cancellation_reason, cancelled_by: 'customer')
      super()
      @order = order
      @cancellation_reason = cancellation_reason
      @cancelled_by = cancelled_by
    end

    def call
      ActiveRecord::Base.transaction do
        validate_cancellation!
        restore_inventory
        update_order_status
        update_status_history
        send_cancellation_email
        handle_refund_if_needed
        set_result(@order)
      end
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_cancellation!
      unless @order.can_be_cancelled?
        add_error('Order cannot be cancelled')
        raise StandardError, 'Order cannot be cancelled'
      end

      if @cancellation_reason.blank?
        add_error('Cancellation reason is required')
        raise StandardError, 'Cancellation reason is required'
      end

      if @cancellation_reason.length < 10
        add_error('Cancellation reason must be at least 10 characters')
        raise StandardError, 'Cancellation reason must be at least 10 characters'
      end
    end

    def restore_inventory
      @order.order_items.each do |item|
        variant = item.product_variant
        # Restore stock quantity
        variant.increment!(:stock_quantity, item.quantity)
        # Decrease reserved quantity
        if variant.reserved_quantity.to_i > 0
          variant.decrement!(:reserved_quantity, item.quantity)
        end
        # Update availability flags (handled by ProductVariant callback)
        # Update availability flags using service
        # Note: variant is saved by increment!/decrement! above, so callback will handle it
        # But we call service directly to ensure flags are updated immediately
        if variant.respond_to?(:update_availability_flags)
          availability_service = Products::VariantAvailabilityService.new(variant)
          availability_service.call
        end
        
        # Update order item fulfillment status
        item.update!(fulfillment_status: 'cancelled')
      end
    end

    def update_order_status
      @order.status = 'cancelled'
      @order.cancellation_reason = @cancellation_reason
      @order.cancelled_at = Time.current
      @order.cancelled_by = @cancelled_by
      @order.save!
    end

    def update_status_history
      notes = "Cancelled by #{@cancelled_by}: #{@cancellation_reason}"
      @order.add_status_to_history('cancelled', notes: notes)
    end

    def send_cancellation_email
      Orders::EmailService.send_cancellation(@order)
    end

    def handle_refund_if_needed
      return unless @order.payment_status == 'payment_complete' && @order.payments.any?
      
      # Log that refund should be processed
      # TODO: Integrate with payment gateway to process refund
      Rails.logger.info "Order #{@order.id} cancelled - Refund should be processed for payment #{@order.payments.first.id}"
      # Could create a PaymentRefund record here via Payments::RefundCreationService
    end
  end
end

