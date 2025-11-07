# frozen_string_literal: true

class Api::V1::ShipmentsController < ApplicationController
  before_action :set_shipment, only: [:show, :tracking]
  before_action :authorize_supplier!, only: [:create, :add_tracking_event]

  # GET /api/v1/orders/:order_id/shipments
  def index
    @order = current_user.orders.find(params[:order_id])
    @shipments = @order.shipments.includes(:shipping_method, :shipment_tracking_events).order(created_at: :desc)
    
    render_success(format_shipments_data(@shipments), 'Shipments retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  # GET /api/v1/shipments/:id
  def show
    # Check authorization
    if @shipment.order.user_id != current_user.id && !current_user.supplier?
      render_unauthorized('Not authorized')
      return
    end
    
    render_success(format_shipment_detail_data(@shipment), 'Shipment retrieved successfully')
  end

  # GET /api/v1/shipments/:id/tracking
  def tracking
    @tracking_events = @shipment.shipment_tracking_events.order(:event_time)
    
    render_success({
      shipment: format_shipment_data(@shipment),
      tracking_events: format_tracking_events_data(@tracking_events)
    }, 'Tracking information retrieved successfully')
  end

  # POST /api/v1/supplier/shipments
  def create
    authorize_supplier!
    ensure_supplier_profile!
    
    @order_item = OrderItem.where(supplier_profile_id: current_user.supplier_profile.id)
                          .find(params[:order_item_id])
    
    @shipment = @order_item.shipments.build(shipment_params)
    @shipment.order = @order_item.order
    @shipment.status = 'pending'
    
    if @shipment.save
      render_created(format_shipment_detail_data(@shipment), 'Shipment created successfully')
    else
      render_validation_errors(@shipment.errors.full_messages, 'Shipment creation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # POST /api/v1/supplier/shipments/:id/tracking_events
  def add_tracking_event
    authorize_supplier!
    ensure_supplier_profile!
    
    @tracking_event = @shipment.shipment_tracking_events.build(tracking_event_params)
    @tracking_event.event_time ||= Time.current
    
    if @tracking_event.save
      # Update shipment status if needed
      if ['delivered', 'failed', 'returned'].include?(@tracking_event.event_type)
        @shipment.update(status: @tracking_event.event_type)
      end
      
      render_created(format_tracking_event_data(@tracking_event), 'Tracking event added successfully')
    else
      render_validation_errors(@tracking_event.errors.full_messages, 'Tracking event creation failed')
    end
  end

  private

  def set_shipment
    @shipment = Shipment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Shipment not found')
  end

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

  def shipment_params
    params.require(:shipment).permit(
      :shipping_method_id,
      :shipping_provider,
      :tracking_number,
      :tracking_url,
      :from_address,
      :to_address,
      :weight_kg,
      :length_cm,
      :width_cm,
      :height_cm,
      :shipping_charge,
      :cod_charge
    )
  end

  def tracking_event_params
    params.require(:tracking_event).permit(
      :event_type,
      :event_description,
      :location,
      :city,
      :state,
      :pincode,
      :event_time,
      :source
    )
  end

  def format_shipments_data(shipments)
    shipments.map { |s| format_shipment_data(s) }
  end

  def format_shipment_data(shipment)
    {
      id: shipment.id,
      shipment_id: shipment.shipment_id,
      order_id: shipment.order_id,
      order_item_id: shipment.order_item_id,
      shipping_provider: shipment.shipping_provider,
      tracking_number: shipment.tracking_number,
      tracking_url: shipment.tracking_url,
      status: shipment.status,
      shipped_at: shipment.shipped_at,
      estimated_delivery_date: shipment.estimated_delivery_date,
      actual_delivery_date: shipment.actual_delivery_date,
      created_at: shipment.created_at
    }
  end

  def format_shipment_detail_data(shipment)
    format_shipment_data(shipment).merge(
      from_address: shipment.from_address_data,
      to_address: shipment.to_address_data,
      weight_kg: shipment.weight_kg&.to_f,
      shipping_charge: shipment.shipping_charge&.to_f,
      cod_charge: shipment.cod_charge&.to_f,
      tracking_events: format_tracking_events_data(shipment.shipment_tracking_events.order(:event_time))
    )
  end

  def format_tracking_events_data(events)
    events.map do |event|
      {
        id: event.id,
        event_type: event.event_type,
        event_description: event.event_description,
        location: event.location,
        city: event.city,
        state: event.state,
        pincode: event.pincode,
        event_time: event.event_time,
        source: event.source,
        created_at: event.created_at
      }
    end
  end

  def format_tracking_event_data(event)
    {
      id: event.id,
      event_type: event.event_type,
      event_description: event.event_description,
      location: event.location,
      city: event.city,
      state: event.state,
      pincode: event.pincode,
      event_time: event.event_time,
      source: event.source
    }
  end
end


