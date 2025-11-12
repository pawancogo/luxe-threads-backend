class Api::V1::SupplierProfilesController < ApplicationController
  before_action :authorize_supplier!

  def show
    @profile = current_user.supplier_profile
    if @profile
      render_success(
        SupplierProfileSerializer.new(@profile).as_json,
        'Supplier profile retrieved successfully'
      )
    else
      render_not_found('Supplier profile not found. Please create a supplier profile first.')
    end
  end

  def create
    service = Suppliers::ProfileCreationService.new(current_user, profile_params)
    service.call
    
    if service.success?
      render_created(
        SupplierProfileSerializer.new(service.profile).as_json,
        'Supplier profile created successfully'
      )
    else
      render_validation_errors(service.errors, 'Supplier profile creation failed')
    end
  end

  def update
    service = Suppliers::ProfileUpdateService.new(current_user, profile_params)
    service.call
    
    if service.success?
      render_success(
        SupplierProfileSerializer.new(service.profile).as_json,
        'Supplier profile updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Supplier profile update failed')
    end
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def profile_params
    # Phase 1: Allow Phase 1 fields, but only allow suppliers to update certain fields
    # Admin-only fields (supplier_tier, is_suspended, etc.) are managed by admin controllers
    params.require(:supplier_profile).permit(
      :company_name,
      :gst_number,
      :description,
      :website_url,
      :contact_email,
      :contact_phone,
      :support_email,
      :support_phone,
      :business_type,
      :business_category,
      :company_registration_number,
      :pan_number,
      :cin_number
      # Note: supplier_tier, is_suspended, is_active are admin-only fields
    )
  end

end