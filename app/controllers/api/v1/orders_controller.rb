class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  # GET /api/v1/my-orders or /api/v1/orders
  def index
    @orders = current_user.orders.includes(
      :shipping_address,
      :billing_address,
      order_items: { product_variant: { product: [:brand, :category, product_variants: :product_images] } }
    ).order(created_at: :desc)
    
    render_success(format_orders_data(@orders), 'Orders retrieved successfully')
  end

  # GET /api/v1/my-orders/:id or /api/v1/orders/:id
  def show
    render_success(format_order_detail_data(@order), 'Order retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  # POST /api/v1/orders
  def create
    cart = current_user.cart
    return render_validation_errors(['Cart is empty'], 'Cannot create order with empty cart') if cart.cart_items.empty?

    @order = current_user.orders.build(order_params.except(:payment_method_id))
    @order.status = 'pending'
    @order.total_amount = calculate_total(cart)
    
    # For now, we'll skip payment integration - you can add Stripe later
    # If payment_method_id is provided, integrate with payment gateway
    if params[:order][:payment_method_id].present?
      # TODO: Integrate with Stripe or other payment gateway
      # For now, we'll just create the order
    end
    
    ActiveRecord::Base.transaction do
      transfer_cart_items_to_order(cart, @order)
      @order.payment_status = 'pending'
      @order.status = 'pending'
      @order.save!
      cart.cart_items.destroy_all
    end

    render_created(format_order_detail_data(@order), 'Order created successfully')
  rescue ActiveRecord::RecordInvalid => e
    render_validation_errors(e.record.errors.full_messages, 'Order creation failed')
  rescue StandardError => e
    render_error(e.message, 'Order creation failed')
  end

  private

  def calculate_total(cart)
    cart.cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
  end
  
  def transfer_cart_items_to_order(cart, order)
    cart.cart_items.each do |cart_item|
      variant = cart_item.product_variant
      
      # Check stock availability
      if variant.stock_quantity < cart_item.quantity
        raise StandardError, "Insufficient stock for #{variant.sku}. Available: #{variant.stock_quantity}, Requested: #{cart_item.quantity}"
      end
      
      # Create order item
      order.order_items.create!(
        product_variant_id: variant.id,
        quantity: cart_item.quantity,
        price_at_purchase: variant.discounted_price || variant.price
      )
      
      # Decrement stock
      variant.decrement!(:stock_quantity, cart_item.quantity)
    end
  end

  def set_order
    @order = current_user.orders.includes(
      :shipping_address,
      :billing_address,
      order_items: { product_variant: { product: [:brand, :category, product_variants: :product_images] } }
    ).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:shipping_address_id, :billing_address_id, :shipping_method, :payment_method_id)
  end

  def format_orders_data(orders)
    orders.map do |order|
      {
        id: order.id,
        order_number: order.id.to_s.rjust(8, '0'),
        status: order.status,
        payment_status: order.payment_status,
        total_amount: order.total_amount,
        shipping_method: order.shipping_method,
        created_at: order.created_at.iso8601,
        item_count: order.order_items.sum(:quantity),
        items: order.order_items.limit(3).map { |item| format_order_item_summary(item) }
      }
    end
  end

  def format_order_detail_data(order)
    {
      id: order.id,
      order_number: order.id.to_s.rjust(8, '0'),
      status: order.status,
      payment_status: order.payment_status,
      total_amount: order.total_amount,
      shipping_method: order.shipping_method,
      created_at: order.created_at.iso8601,
      shipping_address: format_address(order.shipping_address),
      billing_address: format_address(order.billing_address),
      items: order.order_items.map { |item| format_order_item_detail(item) }
    }
  end

  def format_order_item_summary(order_item)
    variant = order_item.product_variant
    product = variant.product
    {
      id: order_item.id,
      product_name: product.name,
      sku: variant.sku,
      quantity: order_item.quantity,
      price: order_item.price_at_purchase
    }
  end

  def format_order_item_detail(order_item)
    variant = order_item.product_variant
    product = variant.product
    {
      id: order_item.id,
      product: {
        id: product.id,
        name: product.name,
        brand_name: product.brand.name,
        category_name: product.category.name
      },
      variant: {
        id: variant.id,
        sku: variant.sku,
        price: variant.price,
        discounted_price: variant.discounted_price
      },
      quantity: order_item.quantity,
      price_at_purchase: order_item.price_at_purchase,
      subtotal: order_item.quantity * order_item.price_at_purchase,
      image_url: variant.product_images.first&.image_url || product.product_variants.first&.product_images&.first&.image_url
    }
  end

  def format_address(address)
    return nil unless address
    
    {
      id: address.id,
      full_name: address.full_name,
      phone_number: address.phone_number,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      state: address.state,
      postal_code: address.postal_code,
      country: address.country
    }
  end
end