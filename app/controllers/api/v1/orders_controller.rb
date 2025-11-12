# frozen_string_literal: true

# Refactored OrdersController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::OrdersController < ApplicationController
  include EagerLoading
  include ServiceResponseHandler
  
  before_action :set_order, only: [:show, :cancel, :invoice]

  # GET /api/v1/my-orders or /api/v1/orders
  def index
    orders = Order.for_customer(current_user).with_full_details.recent
    
    serialized_orders = orders.map { |order| OrderSerializer.new(order).summary }
    
    render_success(serialized_orders, 'Orders retrieved successfully')
  end

  # GET /api/v1/my-orders/:id or /api/v1/orders/:id
  def show
    # Pass options to serializer - these are automatically passed to nested serializers
    # Nested serializers (OrderItemSerializer, AddressSerializer, etc.) can access via options method
    serializer_options = {
      include_payments: params[:include_payments] == 'true',
      include_refunds: params[:include_refunds] == 'true',
      include_user: params[:include_user] == 'true',
      # Options passed here are available in nested serializers
      include_product_details: params[:include_product_details] == 'true',
      include_product_variant: params[:include_product_variant] == 'true'
    }
    
    render_success(
      OrderSerializer.new(@order, serializer_options).as_json,
      'Order retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  # GET /api/v1/my-orders/:id/invoice
  def invoice
    pdf_data = InvoiceService.generate_pdf(@order)
    
    send_data(
      pdf_data,
      filename: "invoice-#{@order.order_number || @order.id}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
    )
  rescue StandardError => e
    Rails.logger.error "Error generating invoice: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render_error('Failed to generate invoice', 'An error occurred while generating the invoice')
  end

  # PATCH /api/v1/my-orders/:id/cancel
  def cancel
    service = Orders::CancellationService.new(
      @order,
      params[:cancellation_reason]&.strip,
      cancelled_by: 'customer'
    )
    
    service.call
    handle_service_response(
      service,
      success_message: 'Order cancelled successfully',
      error_message: 'Failed to cancel order',
      presenter: OrderSerializer
    )
  end

  # POST /api/v1/orders
  def create
    service = Orders::CreationService.new(
      current_user,
      current_user.cart,
      order_params
    )
    
    service.call
    handle_service_response(
      service,
      success_message: 'Order created successfully',
      error_message: 'Order creation failed',
      presenter: OrderSerializer,
      status: :created
    )
  end

  private

  def set_order
    @order = Order.with_full_details.find(params[:id])
    
    unless @order.user_id == current_user.id
      render_unauthorized('Access denied')
      return
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  def order_params
    params.require(:order).permit(
      :shipping_address_id,
      :billing_address_id,
      :shipping_method,
      :payment_method_id,
      :coupon_code
    )
  end
end