class Api::V1::AddressesController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def index
    @addresses = current_user.addresses
    render json: @addresses
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      render json: @address, status: :created
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      render json: @address
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:address_type, :full_name, :phone_number, :line1, :line2, :city, :state, :postal_code, :country)
  end
end