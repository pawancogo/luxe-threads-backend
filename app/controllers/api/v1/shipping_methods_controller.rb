# frozen_string_literal: true

class Api::V1::ShippingMethodsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]
  before_action :authorize_admin!, only: [:admin_index, :admin_create, :admin_update, :admin_destroy]
  before_action :set_shipping_method, only: [:admin_update, :admin_destroy]

  # GET /api/v1/shipping_methods
  def index
    @shipping_methods = ShippingMethod.active.order(:name)
    
    render_success(format_shipping_methods_data(@shipping_methods), 'Shipping methods retrieved successfully')
  end

  # GET /api/v1/admin/shipping_methods
  def admin_index
    @shipping_methods = ShippingMethod.order(:name)
    
    # Filter by active status if provided
    @shipping_methods = @shipping_methods.where(is_active: params[:is_active] == 'true') if params[:is_active].present?
    
    render_success(format_shipping_methods_data(@shipping_methods), 'Shipping methods retrieved successfully')
  end

  # POST /api/v1/admin/shipping_methods
  def admin_create
    shipping_method_params_data = params[:shipping_method] || {}
    
    @shipping_method = ShippingMethod.new(
      name: shipping_method_params_data[:name],
      code: shipping_method_params_data[:code],
      description: shipping_method_params_data[:description],
      provider: shipping_method_params_data[:provider],
      base_charge: shipping_method_params_data[:base_charge],
      per_kg_charge: shipping_method_params_data[:per_kg_charge],
      free_shipping_above: shipping_method_params_data[:free_shipping_above],
      estimated_days_min: shipping_method_params_data[:estimated_days_min],
      estimated_days_max: shipping_method_params_data[:estimated_days_max],
      is_cod_available: shipping_method_params_data[:is_cod_available] || false,
      is_active: shipping_method_params_data[:is_active] != false,
      available_pincodes: shipping_method_params_data[:available_pincodes]&.to_json,
      excluded_pincodes: shipping_method_params_data[:excluded_pincodes]&.to_json
    )
    
    if @shipping_method.save
      render_created(format_shipping_method_detail_data(@shipping_method), 'Shipping method created successfully')
    else
      render_validation_errors(@shipping_method.errors.full_messages, 'Shipping method creation failed')
    end
  end

  # PATCH /api/v1/admin/shipping_methods/:id
  def admin_update
    shipping_method_params_data = params[:shipping_method] || {}
    
    update_hash = {}
    update_hash[:name] = shipping_method_params_data[:name] if shipping_method_params_data.key?(:name)
    update_hash[:code] = shipping_method_params_data[:code] if shipping_method_params_data.key?(:code)
    update_hash[:description] = shipping_method_params_data[:description] if shipping_method_params_data.key?(:description)
    update_hash[:provider] = shipping_method_params_data[:provider] if shipping_method_params_data.key?(:provider)
    update_hash[:base_charge] = shipping_method_params_data[:base_charge] if shipping_method_params_data.key?(:base_charge)
    update_hash[:per_kg_charge] = shipping_method_params_data[:per_kg_charge] if shipping_method_params_data.key?(:per_kg_charge)
    update_hash[:free_shipping_above] = shipping_method_params_data[:free_shipping_above] if shipping_method_params_data.key?(:free_shipping_above)
    update_hash[:estimated_days_min] = shipping_method_params_data[:estimated_days_min] if shipping_method_params_data.key?(:estimated_days_min)
    update_hash[:estimated_days_max] = shipping_method_params_data[:estimated_days_max] if shipping_method_params_data.key?(:estimated_days_max)
    update_hash[:is_cod_available] = shipping_method_params_data[:is_cod_available] if shipping_method_params_data.key?(:is_cod_available)
    update_hash[:is_active] = shipping_method_params_data[:is_active] if shipping_method_params_data.key?(:is_active)
    update_hash[:available_pincodes] = shipping_method_params_data[:available_pincodes]&.to_json if shipping_method_params_data.key?(:available_pincodes)
    update_hash[:excluded_pincodes] = shipping_method_params_data[:excluded_pincodes]&.to_json if shipping_method_params_data.key?(:excluded_pincodes)
    
    if @shipping_method.update(update_hash)
      render_success(format_shipping_method_detail_data(@shipping_method), 'Shipping method updated successfully')
    else
      render_validation_errors(@shipping_method.errors.full_messages, 'Shipping method update failed')
    end
  end

  # DELETE /api/v1/admin/shipping_methods/:id
  def admin_destroy
    if @shipping_method.destroy
      render_success({ id: @shipping_method.id }, 'Shipping method deleted successfully')
    else
      render_validation_errors(@shipping_method.errors.full_messages, 'Shipping method deletion failed')
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

  def format_shipping_methods_data(methods)
    methods.map do |method|
      {
        id: method.id,
        name: method.name,
        code: method.code,
        description: method.description,
        provider: method.provider,
        base_charge: method.base_charge&.to_f || 0,
        per_kg_charge: method.per_kg_charge&.to_f || 0,
        free_shipping_above: method.free_shipping_above&.to_f,
        estimated_days_min: method.estimated_days_min,
        estimated_days_max: method.estimated_days_max,
        is_cod_available: method.is_cod_available || false
      }
    end
  end

  def format_shipping_method_detail_data(method)
    format_shipping_methods_data([method]).first.merge(
      is_active: method.is_active,
      available_pincodes: method.available_pincodes_list,
      excluded_pincodes: method.excluded_pincodes_list,
      created_at: method.created_at,
      updated_at: method.updated_at
    )
  end
end


