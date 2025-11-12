# frozen_string_literal: true

# Refactored PaymentRefundsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::PaymentRefundsController < ApplicationController
  before_action :set_payment_refund, only: [:show]

  # GET /api/v1/payment_refunds
  def index
    refunds = if current_user.admin?
      PaymentRefund.with_full_details
    else
      PaymentRefund.for_customer(current_user.id).with_full_details
    end
    
    refunds = refunds.by_status(params[:status]) if params[:status].present?
    refunds = refunds.for_order(params[:order_id]) if params[:order_id].present?
    refunds = refunds.order(created_at: :desc)
    
    serialized_refunds = refunds.map { |refund| PaymentRefundSerializer.new(refund).as_json }
    render_success(serialized_refunds, 'Refunds retrieved successfully')
  end

  # GET /api/v1/payment_refunds/:id
  def show
    unless @payment_refund.payment.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized')
      return
    end
    
    render_success(
      PaymentRefundSerializer.new(@payment_refund).detailed,
      'Refund retrieved successfully'
    )
  end

  # POST /api/v1/payment_refunds
  def create
    payment = Payment.find(params[:payment_id])
    
    service = Payments::RefundCreationService.new(payment, params[:refund] || {}, current_user)
    service.call
    
    if service.success?
      render_created(
        PaymentRefundSerializer.new(service.payment_refund).detailed,
        'Refund created successfully'
      )
    else
      render_validation_errors(service.errors, 'Refund creation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Payment not found')
  end

  private

  def set_payment_refund
    @payment_refund = PaymentRefund.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Refund not found')
  end
end

