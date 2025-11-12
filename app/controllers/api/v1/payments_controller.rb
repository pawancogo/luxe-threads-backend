# frozen_string_literal: true

# Refactored PaymentsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::PaymentsController < ApplicationController
  before_action :set_order, only: [:create]
  before_action :set_payment, only: [:show, :refund]

  # POST /api/v1/orders/:order_id/payments
  def create
    service = Payments::CreationService.new(@order, current_user, payment_params)
    service.call
    
    if service.success?
      render_created(
        PaymentSerializer.new(service.payment).as_json,
        'Payment created successfully'
      )
    else
      render_validation_errors(service.errors, 'Payment creation failed')
    end
  end

  # GET /api/v1/payments/:id
  def show
    render_success(
      PaymentSerializer.new(@payment).as_json,
      'Payment retrieved successfully'
    )
  end

  # POST /api/v1/payments/:id/refund
  def refund
    service = Payments::RefundService.new(@payment, params[:refund] || {}, current_user)
    service.call
    
    if service.success?
      render_created(
        PaymentRefundSerializer.new(service.refund).as_json,
        'Refund processed successfully'
      )
    else
      render_validation_errors(service.errors, 'Refund processing failed')
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
    unless @payment.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized')
      return
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
end



