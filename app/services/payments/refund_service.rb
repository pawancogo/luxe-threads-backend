# frozen_string_literal: true

# Service for processing payment refunds
module Payments
  class RefundService < BaseService
    attr_reader :payment, :refund

    def initialize(payment, refund_params, user)
      super()
      @payment = payment
      @refund_params = refund_params
      @user = user
    end

    def call
      validate_payment!
      create_refund
      update_payment_status
      set_result(@refund)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_payment!
      unless @payment
        add_error('Payment is required')
        raise StandardError, 'Payment not found'
      end

      # Ensure user can only refund their own payments (unless admin)
      unless @payment.user_id == @user.id || @user.admin?
        add_error('Not authorized to refund this payment')
        raise StandardError, 'Unauthorized'
      end
    end

    def create_refund
      @refund = @payment.payment_refunds.build(
        order: @payment.order,
        amount: @refund_params[:amount] || @payment.amount,
        currency: @refund_params[:currency] || @payment.currency,
        reason: @refund_params[:reason] || 'Refund requested',
        description: @refund_params[:description],
        status: 'pending'
      )
      
      unless @refund.save
        add_errors(@refund.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @refund
      end
    end

    def update_payment_status
      if @refund.amount >= @payment.amount
        @payment.update!(status: 'refunded')
      else
        @payment.update!(status: 'partially_refunded')
      end
    end
  end
end

