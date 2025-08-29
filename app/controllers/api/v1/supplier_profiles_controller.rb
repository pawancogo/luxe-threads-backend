class Api::V1::SupplierProfilesController < ApplicationController
  before_action :authorize_supplier!

  def show
    @profile = current_user.supplier_profile
    if @profile
      render json: @profile
    else
      render json: { error: 'Supplier profile not found.' }, status: :not_found
    end
  end

  def create
    @profile = current_user.build_supplier_profile(profile_params)
    if @profile.save
      render json: @profile, status: :created
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @profile = current_user.supplier_profile
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def profile_params
    params.require(:supplier_profile).permit(:company_name, :gst_number, :description, :website_url)
  end
end