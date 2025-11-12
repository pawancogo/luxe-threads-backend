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

    formatting_service = SupplierOrdersFormattingService.new(@order_items)
    formatting_service.call
    
    formatted_data = formatting_service.formatted_orders.map do |order_data|
      SupplierOrderSerializer.new(order_data).as_json
    end
    
    render_success(formatted_data, 'Supplier orders retrieved successfully')
  end

  # GET /api/v1/supplier/orders/:item_id
  def show
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    render_success(
      OrderItemSerializer.new(@order_item).as_json,
      'Order item retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # POST /api/v1/supplier/orders/:item_id/confirm
  def confirm
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    service = Orders::ItemConfirmationService.new(@order_item)
    service.call
    
    if service.success?
      render_success(
        OrderItemSerializer.new(@order_item.reload).as_json,
        'Order item confirmed successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to confirm order item')
    end
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

    tracking_number = params[:tracking_number] || params.dig(:supplier_order, :tracking_number)
    
    service = Orders::ItemShipmentService.new(@order_item, tracking_number)
    service.call
    
    if service.success?
      render_success(
        OrderItemSerializer.new(@order_item.reload).as_json,
        'Order item marked as shipped successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to ship order item')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # PUT /api/v1/supplier/orders/:item_id/update_tracking
  def update_tracking
    supplier_profile = current_user.supplier_profile

    @order_item = OrderItem.where(supplier_profile_id: supplier_profile.id)
                          .find(params[:item_id])

    tracking_number = params[:tracking_number] || params.dig(:supplier_order, :tracking_number)
    tracking_url = params[:tracking_url] || params.dig(:supplier_order, :tracking_url)
    
    service = Orders::ItemTrackingUpdateService.new(@order_item, tracking_number, tracking_url: tracking_url)
    service.call
    
    if service.success?
      render_success(
        OrderItemSerializer.new(@order_item.reload).as_json,
        'Tracking information updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to update tracking')
    end
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

end
