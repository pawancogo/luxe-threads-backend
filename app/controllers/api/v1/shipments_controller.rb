# frozen_string_literal: true

class Api::V1::ShipmentsController < ApplicationController
  before_action :set_shipment, only: [:show, :tracking]
  before_action :authorize_supplier!, only: [:create, :add_tracking_event]

  # GET /api/v1/orders/:order_id/shipments
  def index
    @order = current_user.orders.find(params[:order_id])
    @shipments = @order.shipments.includes(:shipping_method, :shipment_tracking_events).order(created_at: :desc)
    
    render_success(
      ShipmentSerializer.collection(@shipments),
      'Shipments retrieved successfully'
    )
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
    
    render_success(
      ShipmentSerializer.new(@shipment).as_json,
      'Shipment retrieved successfully'
    )
  end

  # GET /api/v1/shipments/:id/tracking
  def tracking
    @tracking_events = @shipment.shipment_tracking_events.order(:event_time)
    
    render_success({
      shipment: ShipmentSerializer.new(@shipment).as_json,
      tracking_events: ShipmentTrackingEventSerializer.collection(@tracking_events)
    }, 'Tracking information retrieved successfully')
  end

  # POST /api/v1/supplier/shipments
  def create
    authorize_supplier!
    ensure_supplier_profile!
    
    @order_item = OrderItem.where(supplier_profile_id: current_user.supplier_profile.id)
                          .find(params[:order_item_id])
    
    service = Shipments::CreationService.new(@order_item, shipment_params)
    service.call
    
    if service.success?
      render_created(
        ShipmentSerializer.new(service.shipment).as_json,
        'Shipment created successfully'
      )
    else
      render_validation_errors(service.errors, 'Shipment creation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order item not found')
  end

  # POST /api/v1/supplier/shipments/:id/tracking_events
  def add_tracking_event
    authorize_supplier!
    ensure_supplier_profile!
    
    service = Shipments::TrackingEventService.new(@shipment, tracking_event_params)
    service.call
    
    if service.success?
      render_created(
        ShipmentTrackingEventSerializer.new(service.tracking_event).as_json,
        'Tracking event added successfully'
      )
    else
      render_validation_errors(service.errors, 'Tracking event creation failed')
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

end



