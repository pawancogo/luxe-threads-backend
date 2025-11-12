# frozen_string_literal: true

# Refactored ShippingMethodsController using Clean Architecture
# Controller → Model → Serializer
class Api::V1::ShippingMethodsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]
  before_action :authorize_admin!, only: [:admin_index, :admin_create, :admin_update, :admin_destroy]
  before_action :set_shipping_method, only: [:admin_update, :admin_destroy]

  # GET /api/v1/shipping_methods
  def index
    service = ShippingMethodListingService.new(ShippingMethod.active, params)
    service.call
    
    if service.success?
      serialized_methods = service.shipping_methods.map { |method| ShippingMethodSerializer.new(method).as_json }
      render_success(serialized_methods, 'Shipping methods retrieved successfully')
    else
      render_validation_errors(service.errors, 'Failed to retrieve shipping methods')
    end
  end

  # GET /api/v1/admin/shipping_methods
  def admin_index
    service = ShippingMethodListingService.new(ShippingMethod.all, params)
    service.call
    
    if service.success?
      serialized_methods = service.shipping_methods.map { |method| ShippingMethodSerializer.new(method).as_json }
      render_success(serialized_methods, 'Shipping methods retrieved successfully')
    else
      render_validation_errors(service.errors, 'Failed to retrieve shipping methods')
    end
  end

  # POST /api/v1/admin/shipping_methods
  def admin_create
    service = Shipping::CreationService.new(shipping_method_params)
    service.call
    
    if service.success?
      render_created(
        ShippingMethodSerializer.new(service.shipping_method).detailed,
        'Shipping method created successfully'
      )
    else
      render_validation_errors(service.errors, 'Shipping method creation failed')
    end
  end

  # PATCH /api/v1/admin/shipping_methods/:id
  def admin_update
    service = Shipping::UpdateService.new(@shipping_method, shipping_method_update_params)
    service.call
    
    if service.success?
      render_success(
        ShippingMethodSerializer.new(@shipping_method.reload).detailed,
        'Shipping method updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Shipping method update failed')
    end
  end

  # DELETE /api/v1/admin/shipping_methods/:id
  def admin_destroy
    service = Shipping::DeletionService.new(@shipping_method)
    service.call
    
    if service.success?
      render_success({ id: @shipping_method.id }, 'Shipping method deleted successfully')
    else
      render_validation_errors(service.errors, 'Shipping method deletion failed')
    end
  end

  private

  def set_shipping_method
    @shipping_method = ShippingMethod.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Shipping method not found')
  end

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end

  def shipping_method_params
    params_data = params[:shipping_method] || {}
    {
      name: params_data[:name],
      code: params_data[:code],
      description: params_data[:description],
      provider: params_data[:provider],
      base_charge: params_data[:base_charge],
      per_kg_charge: params_data[:per_kg_charge],
      free_shipping_above: params_data[:free_shipping_above],
      estimated_days_min: params_data[:estimated_days_min],
      estimated_days_max: params_data[:estimated_days_max],
      is_cod_available: params_data[:is_cod_available] || false,
      is_active: params_data[:is_active] != false,
      available_pincodes: params_data[:available_pincodes]&.to_json,
      excluded_pincodes: params_data[:excluded_pincodes]&.to_json
    }
  end

  def shipping_method_update_params
    params_data = params[:shipping_method] || {}
    update_hash = {}
    
    %i[name code description provider base_charge per_kg_charge free_shipping_above
       estimated_days_min estimated_days_max is_cod_available is_active].each do |key|
      update_hash[key] = params_data[key] if params_data.key?(key)
    end
    
    update_hash[:available_pincodes] = params_data[:available_pincodes]&.to_json if params_data.key?(:available_pincodes)
    update_hash[:excluded_pincodes] = params_data[:excluded_pincodes]&.to_json if params_data.key?(:excluded_pincodes)
    
    update_hash
  end
end


