class Api::V1::SupplierOrdersController < ApplicationController
  before_action :authorize_supplier!

  # GET /api/v1/supplier/orders
  def index
    supplier_profile = current_user.supplier_profile
    return render_unauthorized('Supplier profile not found') unless supplier_profile

    # Get all order items that belong to products from this supplier
    @order_items = OrderItem.joins(product_variant: { product: :supplier_profile })
                           .where(supplier_profiles: { id: supplier_profile.id })
                           .includes(order: [:user, :shipping_address, :billing_address], product_variant: { product: [:brand, :category] })
                           .order(created_at: :desc)

    render_success(format_supplier_orders_data(@order_items), 'Supplier orders retrieved successfully')
  end

  # GET /api/v1/supplier/orders/:item_id
  def show
    supplier_profile = current_user.supplier_profile
    return render_unauthorized('Supplier profile not found') unless supplier_profile

    @order_item = OrderItem.joins(product_variant: { product: :supplier_profile })
                          .where(supplier_profiles: { id: supplier_profile.id })
                          .find(params[:item_id])

    render_success(format_order_item_data(@order_item), 'Order item retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # PUT /api/v1/supplier/orders/:item_id/ship
  def ship
    supplier_profile = current_user.supplier_profile
    return render_unauthorized('Supplier profile not found') unless supplier_profile

    @order_item = OrderItem.joins(product_variant: { product: :supplier_profile })
                          .where(supplier_profiles: { id: supplier_profile.id })
                          .find(params[:item_id])

    @order = @order_item.order
    
    if params[:tracking_number].present?
      @order.update_column(:status, 'shipped') if @order.status == 'paid'
      render_success(format_order_item_data(@order_item), 'Order item marked as shipped successfully')
    else
      render_validation_errors(['Tracking number is required'], 'Failed to ship order item')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def format_supplier_orders_data(order_items)
    order_items.group_by(&:order).map do |order, items|
      {
        order_id: order.id,
        order_number: order.id.to_s.rjust(8, '0'),
        order_date: order.created_at.iso8601,
        customer_name: order.user.full_name,
        customer_email: order.user.email,
        status: order.status,
        payment_status: order.payment_status,
        total_amount: order.total_amount,
        shipping_address: format_address(order.shipping_address),
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
      product_name: product.name,
      brand_name: product.brand.name,
      category_name: product.category.name,
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
