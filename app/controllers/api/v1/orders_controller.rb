class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders
    render json: @orders.includes(:order_items)
  end

  def show
    render json: @order.as_json(include: { order_items: { include: :product_variant } })
  end

  # POST /api/v1/orders
  def create
    cart = current_user.cart
    return render json: { error: 'Cart is empty' }, status: :unprocessable_entity if cart.cart_items.empty?

    # We will now create the order in a 'pending' state first
    @order = current_user.orders.build(order_params.except(:payment_method_id))
    @order.status = 'pending' # Initial status
    @order.total_amount = calculate_total(cart)
    
    # We create the Payment Intent with Stripe here
    begin
      payment_intent = Stripe::PaymentIntent.create(
        amount: (@order.total_amount * 100).to_i, # Amount in cents
        currency: 'usd',
        payment_method: params[:order][:payment_method_id],
        confirm: true,
        metadata: { order_id: @order.id } # Link intent to our order
      )

      # If payment is successful, we proceed with saving the order
      ActiveRecord::Base.transaction do
        transfer_cart_items_to_order(cart, @order)
        @order.payment_status = 'complete'
        @order.status = 'paid' # Or 'processing'
        @order.save!
        cart.cart_items.destroy_all
      end

      render json: { order: @order, client_secret: payment_intent.client_secret }, status: :created
    
    rescue Stripe::CardError => e
      render json: { errors: e.message }, status: :payment_required
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def calculate_total(cart)
    cart.cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
  end
  
  def transfer_cart_items_to_order(cart, order)
    cart.cart_items.each do |cart_item|
      # ... logic from previous sprint to build order items and decrement stock
    end
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:shipping_address_id, :billing_address_id, :shipping_method, :payment_method_id)
  end
end