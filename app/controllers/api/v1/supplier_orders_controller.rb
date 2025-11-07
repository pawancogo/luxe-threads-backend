class Api::V1::SupplierOrdersController < ApplicationController
  include ApiFormatters
  
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!

  # GET /api/v1/supplier/orders
  def index
    supplier_profile = current_user.supplier_profile

    # Get all order items that belong to products from this supplier (Phase 2: Use supplier_profile_id directly)
    @order_items = OrderItem.where(supplier_profile_id: supplier_profile.id)
                           .includes(order: [:user, :shipping_address, :billing_address], product_variant: { product: [:brand, :category] })
                           .order(created_at: :desc)

    render_success(format_supplier_orders_data(@order_items), 'Supplier orders retrieved successfully')
  end

  # GET /api/v1/supplier/orders/:item_id
  def show
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    render_success(format_order_item_data(@order_item), 'Order item retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # POST /api/v1/supplier/orders/:item_id/confirm
  def confirm
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    @order = @order_item.order
    
    # Only allow confirmation if order is in pending or paid status
    unless @order.status == 'pending' || @order.status == 'paid'
      render_validation_errors(['Order cannot be confirmed in current status'], 'Invalid order status')
      return
    end
    
    # Update order item fulfillment status to processing
    @order_item.update!(
      fulfillment_status: 'processing'
    )
    
    # Update order status to packed if all items are confirmed/processing
    check_and_update_order_status(@order)
    
    render_success(format_order_item_data(@order_item.reload), 'Order item confirmed successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  rescue StandardError => e
    Rails.logger.error "Error confirming order item: #{e.message}"
    render_error('Failed to confirm order item', 'Internal server error')
  end

  # PUT /api/v1/supplier/orders/:item_id/ship
  def ship
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    @order = @order_item.order
    
    tracking_number = params[:tracking_number] || params.dig(:supplier_order, :tracking_number)
    
    if tracking_number.present?
      # Update order status and tracking number
      @order.update_columns(
        status: 'shipped',
        tracking_number: tracking_number,
        updated_at: Time.current
      ) if @order.status == 'paid' || @order.status == 'packed'
      
      # Update order item fulfillment status if the field exists
      if @order_item.respond_to?(:fulfillment_status)
        @order_item.update_columns(
          fulfillment_status: 'shipped',
          shipped_at: Time.current,
          tracking_number: tracking_number,
          updated_at: Time.current
        ) rescue nil
      end
      
      render_success(format_order_item_data(@order_item.reload), 'Order item marked as shipped successfully')
    else
      render_validation_errors(['Tracking number is required'], 'Failed to ship order item')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # PUT /api/v1/supplier/orders/:item_id/update_tracking
  def update_tracking
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    @order = @order_item.order
    
    tracking_number = params[:tracking_number] || params.dig(:supplier_order, :tracking_number)
    tracking_url = params[:tracking_url] || params.dig(:supplier_order, :tracking_url)
    
    unless tracking_number.present?
      render_validation_errors(['Tracking number is required'], 'Failed to update tracking')
      return
    end
    
    # Only allow tracking update if order is shipped or order item is shipped
    unless @order.status == 'shipped' || @order_item.fulfillment_status == 'shipped'
      render_validation_errors(['Tracking can only be updated for shipped orders'], 'Invalid order status')
      return
    end
    
    # Update order item tracking
    @order_item.update!(
      tracking_number: tracking_number,
      tracking_url: tracking_url,
      updated_at: Time.current
    )
    
    # Update order tracking if it's different
    if @order.tracking_number != tracking_number
      @order.update!(
        tracking_number: tracking_number,
        tracking_url: tracking_url,
        updated_at: Time.current
      )
    end
    
    render_success(format_order_item_data(@order_item.reload), 'Tracking information updated successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  rescue StandardError => e
    Rails.logger.error "Error updating tracking: #{e.message}"
    render_error('Failed to update tracking information', 'Internal server error')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(['Supplier profile not found. Please create a supplier profile first.'], 'Supplier profile required')
      return
    end
  end

  def format_supplier_orders_data(order_items)
    order_items.group_by(&:order).map do |order, items|
      {
        order_id: order.id,
        order_number: order.order_number || order.id.to_s.rjust(8, '0'),
        order_date: order.created_at.iso8601,
        customer_name: order.user.full_name,
        customer_email: order.user.email,
        status: order.status,
        payment_status: order.payment_status,
        total_amount: order.total_amount,
        currency: order.currency || 'INR',
        tracking_number: order.tracking_number,
        tracking_url: order.tracking_url,
        estimated_delivery_date: order.estimated_delivery_date&.iso8601,
        shipping_address: format_address_data(order.shipping_address),
        status_history: order.status_history_array,
        items: items.map { |item| format_order_item_data(item) }
      }
    end
  end

  def format_order_item_data(order_item)
    variant = order_item.product_variant
    product = variant.product
    {
      order_item_id: order_item.id,
      product_variant_id: variant.id,
      sku: variant.sku,
      product_name: order_item.product_name || product.name,
      brand_name: product.brand.name,
      category_name: product.category.name,
      quantity: order_item.quantity,
      price_at_purchase: order_item.price_at_purchase,
      discounted_price: order_item.discounted_price,
      final_price: order_item.final_price,
      subtotal: order_item.subtotal,
      currency: order_item.currency || 'INR',
      fulfillment_status: order_item.fulfillment_status,
      tracking_number: order_item.tracking_number,
      tracking_url: order_item.tracking_url,
      shipped_at: order_item.shipped_at&.iso8601,
      delivered_at: order_item.delivered_at&.iso8601,
      is_returnable: order_item.is_returnable,
      return_deadline: order_item.return_deadline&.iso8601,
      can_return: order_item.can_return?,
      image_url: order_item.product_image_url || variant.product_images.first&.image_url || product.product_variants.first&.product_images&.first&.image_url
    }
  end

  # Helper method to check and update order status based on order items
  def check_and_update_order_status(order)
    # Check if all order items are at least processing/packed
    all_items_processing = order.order_items.all? do |item|
      ['processing', 'packed', 'shipped', 'delivered'].include?(item.fulfillment_status)
    end
    
    # Check if all items are packed
    all_items_packed = order.order_items.all? do |item|
      ['packed', 'shipped', 'delivered'].include?(item.fulfillment_status)
    end
    
    # Update order status accordingly
    if all_items_packed && order.status == 'paid'
      order.update!(status: 'packed')
    elsif all_items_processing && order.status == 'pending' && order.payment_status == 'payment_complete'
      # If payment is complete and all items are processing, move to paid
      order.update!(status: 'paid') if order.status == 'pending'
    end
  end

  # format_address is now format_address_data in ApiFormatters
end
