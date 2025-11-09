# frozen_string_literal: true

class Api::V1::PaymentsController < ApplicationController
  before_action :set_order, only: [:create]
  before_action :set_payment, only: [:show, :refund]

  # POST /api/v1/orders/:order_id/payments
  def create
    @payment = @order.payments.build(payment_params)
    @payment.user = current_user
    @payment.status = 'pending'
    
    # Generate payment_id if not provided
    @payment.payment_id ||= "PAY-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
    
    if @payment.save
      # TODO: Integrate with payment gateway (Razorpay, Stripe, etc.)
      # For now, we'll just create the payment record
      
      render_created(format_payment_data(@payment), 'Payment created successfully')
    else
      render_validation_errors(@payment.errors.full_messages, 'Payment creation failed')
    end
  end

  # GET /api/v1/payments/:id
  def show
    render_success(format_payment_data(@payment), 'Payment retrieved successfully')
  end

  # POST /api/v1/payments/:id/refund
  def refund
    refund_params_data = params[:refund] || {}
    
    @refund = @payment.payment_refunds.build(
      order: @payment.order,
      amount: refund_params_data[:amount] || @payment.amount,
      currency: refund_params_data[:currency] || @payment.currency,
      reason: refund_params_data[:reason] || 'Refund requested',
      description: refund_params_data[:description],
      status: 'pending'
    )
    
    if @refund.save
      # Update payment refund status
      if @refund.amount >= @payment.amount
        @payment.update(status: 'refunded')
      else
        @payment.update(status: 'partially_refunded')
      end
      
      render_created(format_refund_data(@refund), 'Refund processed successfully')
    else
      render_validation_errors(@refund.errors.full_messages, 'Refund processing failed')
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  def set_payment
    @payment = Payment.find(params[:id])
    # Ensure user can only access their own payments
    unless @payment.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Payment not found')
  end

  def payment_params
    params.require(:payment).permit(
      :amount,
      :currency,
      :payment_method,
      :payment_gateway,
      :gateway_transaction_id,
      :gateway_payment_id,
      :card_last4,
      :card_brand,
      :upi_id,
      :wallet_type,
      gateway_response: {}
    )
  end

  def format_payment_data(payment)
    {
      id: payment.id,
      payment_id: payment.payment_id,
      order_id: payment.order_id,
      amount: payment.amount.to_f,
      currency: payment.currency,
      payment_method: payment.payment_method,
      payment_gateway: payment.payment_gateway,
      status: payment.status,
      gateway_transaction_id: payment.gateway_transaction_id,
      gateway_payment_id: payment.gateway_payment_id,
      card_last4: payment.card_last4,
      card_brand: payment.card_brand,
      upi_id: payment.upi_id,
      wallet_type: payment.wallet_type,
      refund_amount: payment.refund_amount.to_f,
      refund_status: payment.refund_status,
      created_at: payment.created_at,
      completed_at: payment.completed_at
    }
  end

  def format_refund_data(refund)
    {
      id: refund.id,
      refund_id: refund.refund_id,
      payment_id: refund.payment_id,
      order_id: refund.order_id,
      amount: refund.amount.to_f,
      currency: refund.currency,
      reason: refund.reason,
      status: refund.status,
      gateway_refund_id: refund.gateway_refund_id,
      created_at: refund.created_at,
      processed_at: refund.processed_at
    }
  end
end



