class Api::V1::AddressesController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def index
    @addresses = current_user.addresses
    render_success(format_collection_data(@addresses), 'Addresses retrieved successfully')
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      render_created(format_model_data(@address), 'Address created successfully')
    else
      render_validation_errors(@address.errors.full_messages, 'Address creation failed')
    end
  end

  def update
    if @address.update(address_params)
      render_success(format_model_data(@address), 'Address updated successfully')
    else
      render_validation_errors(@address.errors.full_messages, 'Address update failed')
    end
  end

  def destroy
    @address.destroy
    render_no_content('Address deleted successfully')
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Address not found')
  end

  def address_params
    params.require(:address).permit(:address_type, :full_name, :phone_number, :line1, :line2, :city, :state, :postal_code, :country, :is_default_shipping, :is_default_billing, :label, :alternate_phone, :landmark, :delivery_instructions)
  end
end