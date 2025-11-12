# frozen_string_literal: true

# Refactored AddressesController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::AddressesController < ApplicationController
  include ServiceResponseHandler
  
  before_action :set_address, only: [:update, :destroy]

  def index
    addresses = current_user.addresses.order(created_at: :desc)
    # Pass options to serializer (vendor-backend style)
    serializer_options = { include_user: false }
    serialized_addresses = addresses.map { |addr| AddressSerializer.new(addr, serializer_options).as_json }
    render_success(serialized_addresses, 'Addresses retrieved successfully')
  end

  def create
    service = Addresses::CreationService.new(current_user, address_params)
    service.call
    
    handle_service_response(
      service,
      success_message: 'Address created successfully',
      error_message: 'Address creation failed',
      presenter: AddressSerializer,
      status: :created
    )
  end

  def update
    service = Addresses::UpdateService.new(@address, address_params)
    service.call
    
    if service.success?
      render_success(
        AddressSerializer.new(@address.reload).as_json,
        'Address updated successfully'
      )
    else
      handle_service_errors(service, 'Address update failed')
    end
  end

  def destroy
    service = Addresses::DeletionService.new(@address)
    service.call
    
    if service.success?
      render_no_content('Address deleted successfully')
    else
      handle_service_errors(service, 'Address deletion failed')
    end
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Address not found')
  end

  def address_params
    params.require(:address).permit(
      :address_type, :full_name, :phone_number, :line1, :line2,
      :city, :state, :postal_code, :country, :is_default_shipping,
      :is_default_billing, :label, :alternate_phone, :landmark,
      :delivery_instructions
    )
  end
end