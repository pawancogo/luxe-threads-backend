# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  include ApiFormatters
  include EagerLoading
  
  before_action :set_order, only: [:show, :cancel, :invoice]

  # GET /api/v1/my-orders or /api/v1/orders
  def index
    @orders = with_eager_loading(
      current_user.orders,
      additional_includes: order_includes
    ).order(created_at: :desc)
    
    render_success(format_orders_data(@orders), 'Orders retrieved successfully')
  end

  # GET /api/v1/my-orders/:id or /api/v1/orders/:id
  def show
    render_success(format_order_detail_data(@order), 'Order retrieved successfully')
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
    unless @order.can_be_cancelled?
      render_error('Order cannot be cancelled', 'This order has already been shipped or delivered')
      return
    end

    cancellation_reason = params[:cancellation_reason]&.strip
    
    if cancellation_reason.blank?
      render_validation_errors(['Cancellation reason is required'], 'Please provide a reason for cancellation')
      return
    end
    
    if cancellation_reason.length < 10
      render_validation_errors(['Cancellation reason must be at least 10 characters'], 'Please provide a more detailed reason')
      return
    end

    begin
      @order.cancel!(cancellation_reason, 'customer')
      render_success(format_order_detail_data(@order), 'Order cancelled successfully')
    rescue StandardError => e
      Rails.logger.error "Error cancelling order: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_server_error('Failed to cancel order', e)
    end
  end

  # POST /api/v1/orders
  def create
    cart = current_user.cart
    return render_validation_errors(['Cart is empty'], 'Cannot create order with empty cart') if cart.cart_items.empty?

    @order = current_user.orders.build(order_params.except(:payment_method_id, :coupon_code))
    @order.status = 'pending'
    
    # Calculate subtotal (cart total)
    subtotal = calculate_total(cart)
    
    # Apply coupon if provided
    coupon_code = params[:order][:coupon_code]&.strip&.upcase
    coupon_discount = 0.0
    coupon = nil
    
    if coupon_code.present?
      coupon = Coupon.find_by(code: coupon_code)
      if coupon && coupon.available? && coupon.valid_for_user?(current_user)
        if subtotal >= coupon.min_order_amount
          coupon_discount = coupon.calculate_discount(subtotal)
        end
      end
    end
    
    @order.coupon_discount = coupon_discount
    @order.total_amount = subtotal - coupon_discount
    
    # Payment gateway integration
    # NOTE: Payment gateway integration (Stripe/Razorpay) should be implemented as follows:
    # 1. Create payment intent/order with gateway
    # 2. Store payment intent ID in order
    # 3. After order creation, create Payment record with payment_method_id
    # 4. Handle payment confirmation webhook
    # Current implementation: Orders are created with 'pending' payment status
    # Payment processing should be handled via PaymentsController after order creation
    if params[:order][:payment_method_id].present?
      # Payment will be processed separately via POST /api/v1/orders/:order_id/payments
      # This allows for better error handling and payment retry logic
    end
    
    ActiveRecord::Base.transaction do
      transfer_cart_items_to_order(cart, @order)
      @order.payment_status = 'pending'
      @order.status = 'pending'
      @order.save!
      
      # Create coupon usage if coupon was applied
      if coupon.present? && coupon_discount > 0
        CouponUsage.create!(
          coupon: coupon,
          user: current_user,
          order: @order,
          discount_amount: coupon_discount,
          order_amount: subtotal
        )
      end
      
      cart.cart_items.destroy_all
      
      # Order confirmation email is sent via after_create callback
    end

    render_created(format_order_detail_data(@order), 'Order created successfully')
  rescue ActiveRecord::RecordInvalid => e
    render_validation_errors(e.record.errors.full_messages, 'Order creation failed')
  rescue StandardError => e
    Rails.logger.error "Error creating order: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render_server_error('Order creation failed', e)
  end

  private

  def calculate_total(cart)
    # Eager load variants to avoid N+1
    cart_items = cart.cart_items.includes(:product_variant)
    cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
  end
  
  def transfer_cart_items_to_order(cart, order)
    # Eager load variants and products to avoid N+1
    cart_items = cart.cart_items.includes(product_variant: [:product, :product_images, :product_variant_attributes])
    
    cart_items.each do |cart_item|
      variant = cart_item.product_variant
      product = variant.product
      
      # Check stock availability (Phase 2: Use available_quantity)
      available_qty = variant.available_quantity || (variant.stock_quantity || 0) - (variant.reserved_quantity || 0)
      if available_qty < cart_item.quantity
        raise StandardError, "Insufficient stock for #{variant.sku}. Available: #{available_qty}, Requested: #{cart_item.quantity}"
      end
      
      # Create order item with Phase 2 fields
      final_price = variant.discounted_price || variant.price
      order_item = order.order_items.create!(
        product_variant_id: variant.id,
        supplier_profile_id: product.supplier_profile_id,
        quantity: cart_item.quantity,
        price_at_purchase: final_price,
        discounted_price: variant.discounted_price,
        final_price: final_price,
        product_name: product.name,
        product_image_url: variant.product_images.first&.image_url,
        product_variant_attributes: variant.product_variant_attributes.map { |pva|
          {
            attribute_type: pva.attribute_value.attribute_type.name,
            attribute_value: pva.attribute_value.value
          }
        }.to_json,
        fulfillment_status: 'pending',
        currency: variant.currency || 'INR',
        is_returnable: true
      )
      
      # Decrement stock and update reserved quantity
      variant.decrement!(:stock_quantity, cart_item.quantity)
      variant.increment!(:reserved_quantity, cart_item.quantity)
      variant.update_availability_flags
    end
  end

  def set_order
    @order = with_eager_loading(
      current_user.orders,
      additional_includes: order_includes
    ).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:shipping_address_id, :billing_address_id, :shipping_method, :payment_method_id, :coupon_code)
  end

  def format_orders_data(orders)
    orders.map do |order|
      {
        id: order.id,
        order_number: order.order_number || order.id.to_s.rjust(8, '0'),
        status: order.status,
        payment_status: order.payment_status,
        total_amount: order.total_amount,
        currency: order.currency || 'INR',
        shipping_method: order.shipping_method,
        tracking_number: order.tracking_number,
        estimated_delivery_date: order.estimated_delivery_date&.iso8601,
        created_at: order.created_at.iso8601,
        item_count: order.order_items.sum(:quantity),
        items: order.order_items.limit(3).map { |item| format_order_item_summary(item) }
      }
    end
  end

  def format_order_detail_data(order)
    {
      id: order.id,
      order_number: order.order_number || order.id.to_s.rjust(8, '0'),
      status: order.status,
      payment_status: order.payment_status,
      total_amount: order.total_amount,
      currency: order.currency || 'INR',
      tax_amount: order.tax_amount || 0.0,
      coupon_discount: order.coupon_discount || 0.0,
      shipping_method: order.shipping_method,
      tracking_number: order.tracking_number,
      tracking_url: order.tracking_url,
      estimated_delivery_date: order.estimated_delivery_date&.iso8601,
      actual_delivery_date: order.actual_delivery_date&.iso8601,
      status_history: order.status_history_array,
      created_at: order.created_at.iso8601,
      shipping_address: format_address_data(order.shipping_address),
      billing_address: format_address_data(order.billing_address),
      items: order.order_items.map { |item| format_order_item_detail(item) }
    }
  end

  # format_order_item_summary and format_order_item_detail are now in ApiFormatters
  # format_address is now format_address_data in ApiFormatters
end