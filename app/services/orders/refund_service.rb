# frozen_string_literal: true

# Service for processing admin-initiated order refunds
module Orders
  class RefundService < BaseService
    attr_reader :order, :payment_refund

    def initialize(order, refund_amount, refund_reason: 'Admin refund', admin: nil)
      super()
      @order = order
      @refund_amount = refund_amount.to_f
      @refund_reason = refund_reason
      @admin = admin
    end

    def call
      validate_refund!
      find_payment!
      create_payment_refund
      update_payment_status
      set_result(@payment_refund)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_refund!
      unless @refund_amount > 0
        add_error('Refund amount must be greater than 0')
        raise StandardError, 'Invalid refund amount'
      end

      if @refund_amount > @order.total_amount
        add_error('Refund amount must not exceed order total')
        raise StandardError, 'Invalid refund amount'
      end
    end

    def find_payment!
      @payment = @order.payments.where(status: ['completed', 'refunded']).first
      
      unless @payment
        add_error('No payment found for this order')
        raise StandardError, 'Cannot process refund without payment'
      end
    end

    def create_payment_refund
      @payment_refund = @payment.payment_refunds.create!(
        order: @order,
        amount: @refund_amount,
        currency: @payment.currency || 'INR',
        reason: @refund_reason,
        status: 'pending',
        processed_by: nil # Admin refund - will be processed by payment gateway
      )
    end

    def update_payment_status
      if @refund_amount >= @payment.amount
        @payment.update(status: 'refunded')
      else
        @payment.update(status: 'partially_refunded')
      end
    end
  end
end

