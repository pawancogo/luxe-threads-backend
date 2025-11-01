class Api::V1::SupplierProfilesController < ApplicationController
  before_action :authorize_supplier!

  def show
    @profile = current_user.supplier_profile
    if @profile
      render_success(format_supplier_profile_data(@profile), 'Supplier profile retrieved successfully')
    else
      render_not_found('Supplier profile not found')
    end
  end

  def create
    @profile = current_user.build_supplier_profile(profile_params)
    if @profile.save
      render_created(format_supplier_profile_data(@profile), 'Supplier profile created successfully')
    else
      render_validation_errors(@profile.errors.full_messages, 'Supplier profile creation failed')
    end
  end

  def update
    @profile = current_user.supplier_profile
    if @profile.nil?
      render_not_found('Supplier profile not found')
    elsif @profile.update(profile_params)
      render_success(format_supplier_profile_data(@profile), 'Supplier profile updated successfully')
    else
      render_validation_errors(@profile.errors.full_messages, 'Supplier profile update failed')
    end
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def profile_params
    params.require(:supplier_profile).permit(:company_name, :gst_number, :description, :website_url)
  end

  def format_supplier_profile_data(profile)
    {
      id: profile.id,
      company_name: profile.company_name,
      gst_number: profile.gst_number,
      description: profile.description,
      website_url: profile.website_url,
      verified: profile.verified
    }
  end
end