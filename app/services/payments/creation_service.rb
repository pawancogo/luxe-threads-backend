# frozen_string_literal: true

# Service for creating payments
module Payments
  class CreationService < BaseService
    attr_reader :payment

    def initialize(order, user, payment_params)
      super()
      @order = order
      @user = user
      @payment_params = payment_params
    end

    def call
      validate_order!
      create_payment
      generate_payment_id
      # TODO: Integrate with payment gateway (Razorpay, Stripe, etc.)
      set_result(@payment)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_order!
      unless @order
        add_error('Order is required')
        raise StandardError, 'Order not found'
      end

      unless @order.user_id == @user.id
        add_error('Order does not belong to user')
        raise StandardError, 'Unauthorized'
      end
    end

    def create_payment
      @payment = @order.payments.build(@payment_params)
      @payment.user = @user
      @payment.status = 'pending'
      
      unless @payment.save
        add_errors(@payment.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @payment
      end
    end

    def generate_payment_id
      @payment.payment_id ||= "PAY-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      @payment.save!
    end
  end
end

