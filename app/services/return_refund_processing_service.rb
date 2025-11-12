# frozen_string_literal: true

# Service for processing refunds for return requests
class ReturnRefundProcessingService < BaseService
  attr_reader :return_request, :payment_refund

  def initialize(return_request, refund_amount, admin)
    super()
    @return_request = return_request
    @refund_amount = refund_amount
    @admin = admin
  end

  def call
    validate_status!
    calculate_refund_amount
    create_payment_refund
    process_refund
    update_status_history
    set_result(@return_request)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def validate_status!
    unless ['approved', 'pickup_completed'].include?(@return_request.status)
      add_error('Return request must be approved or pickup completed before processing refund')
      raise StandardError, 'Invalid status for refund'
    end
  end

  def calculate_refund_amount
    @refund_amount ||= @return_request.refund_amount || @return_request.order.total_amount
  end

  def create_payment_refund
    payment = @return_request.order.payments.where(status: ['completed', 'refunded']).first
    return unless payment

    @payment_refund = payment.payment_refunds.create!(
      order: @return_request.order,
      amount: @refund_amount,
      currency: payment.currency,
      reason: 'Return request refund',
      status: 'pending',
      processed_by: @admin
    )
  end

  def process_refund
    unless @return_request.update(
      refund_status: 'processing',
      refund_amount: @refund_amount,
      refund_id: @payment_refund&.refund_id,
      status: 'refund_processing'
    )
      add_errors(@return_request.errors.full_messages)
      raise ActiveRecord::RecordInvalid, @return_request
    end
  end

  def update_status_history
    @return_request.update_status_history('refund_processing', "Refund processing initiated for ₹#{@refund_amount}")
  end
end


