# frozen_string_literal: true

class Api::V1::PaymentRefundsController < ApplicationController
  before_action :set_payment_refund, only: [:show]

  # GET /api/v1/payment_refunds
  def index
    @refunds = PaymentRefund.includes(:payment, :order, :processed_by)
    
    # Filter by user's payments if not admin
    unless current_user.admin?
      @refunds = @refunds.joins(:payment).where(payments: { user_id: current_user.id })
    end
    
    # Filter by status if provided
    @refunds = @refunds.where(status: params[:status]) if params[:status].present?
    
    # Filter by order_id if provided
    @refunds = @refunds.where(order_id: params[:order_id]) if params[:order_id].present?
    
    @refunds = @refunds.order(created_at: :desc)
    
    render_success(format_refunds_data(@refunds), 'Refunds retrieved successfully')
  end

  # GET /api/v1/payment_refunds/:id
  def show
    # Check authorization
    unless @payment_refund.payment.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized')
      return
    end
    
    render_success(format_refund_detail_data(@payment_refund), 'Refund retrieved successfully')
  end

  # POST /api/v1/payment_refunds
  def create
    @payment = Payment.find(params[:payment_id])
    
    # Check authorization
    unless @payment.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized')
      return
    end
    
    refund_params_data = params[:refund] || {}
    
    @payment_refund = @payment.payment_refunds.build(
      order: @payment.order,
      amount: refund_params_data[:amount] || @payment.amount,
      currency: refund_params_data[:currency] || @payment.currency,
      reason: refund_params_data[:reason] || 'Refund requested',
      description: refund_params_data[:description],
      status: 'pending',
      processed_by: current_user.admin? ? current_user : nil
    )
    
    if @payment_refund.save
      # Update payment refund status
      if @payment_refund.amount >= @payment.amount
        @payment.update(status: 'refunded')
      else
        @payment.update(status: 'partially_refunded')
      end
      
      render_created(format_refund_detail_data(@payment_refund), 'Refund created successfully')
    else
      render_validation_errors(@payment_refund.errors.full_messages, 'Refund creation failed')
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

  def format_refunds_data(refunds)
    refunds.map { |refund| format_refund_data(refund) }
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
      created_at: refund.created_at,
      processed_at: refund.processed_at
    }
  end

  def format_refund_detail_data(refund)
    format_refund_data(refund).merge(
      description: refund.description,
      gateway_refund_id: refund.gateway_refund_id,
      gateway_response: refund.gateway_response_data,
      processed_by: refund.processed_by ? {
        id: refund.processed_by.id,
        name: refund.processed_by.full_name
      } : nil,
      payment: {
        id: refund.payment.id,
        payment_id: refund.payment.payment_id,
        amount: refund.payment.amount.to_f
      },
      order: {
        id: refund.order.id,
        order_number: refund.order.order_number || refund.order.id.to_s.rjust(8, '0')
      }
    )
  end
end

