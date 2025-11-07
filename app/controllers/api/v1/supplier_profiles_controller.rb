class Api::V1::SupplierProfilesController < ApplicationController
  before_action :authorize_supplier!

  def show
    @profile = current_user.supplier_profile
    if @profile
      render_success(format_supplier_profile_data(@profile), 'Supplier profile retrieved successfully')
    else
      render_not_found('Supplier profile not found. Please create a supplier profile first.')
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
      render_not_found('Supplier profile not found. Please create a supplier profile first.')
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

  def format_supplier_profile_data(profile)
    # Check if profile has placeholder/temporary values indicating it needs completion
    temp_gst = profile.gst_number&.start_with?('GST') && profile.gst_number.length > 10
    needs_completion = profile.company_name&.include?('please complete') || temp_gst
    
    # Format KYC documents
    kyc_documents = profile.kyc_documents.map do |attachment|
      {
        id: attachment.id,
        filename: attachment.filename.to_s,
        content_type: attachment.content_type,
        byte_size: attachment.byte_size,
        url: url_for_document(attachment),
        created_at: attachment.created_at.iso8601,
        size: ActionController::Base.helpers.number_to_human_size(attachment.byte_size)
      }
    end
    
    # Phase 1: Return all Phase 1 fields
    {
      id: profile.id,
      company_name: profile.company_name,
      gst_number: profile.gst_number,
      description: profile.description,
      website_url: profile.website_url,
      verified: profile.verified,
      needs_completion: needs_completion,
      # Phase 1 fields
      supplier_tier: profile.supplier_tier,
      owner_id: profile.owner_id,
      owner: profile.owner ? {
        id: profile.owner.id,
        first_name: profile.owner.first_name,
        last_name: profile.owner.last_name,
        email: profile.owner.email
      } : nil,
      is_active: profile.is_active,
      is_suspended: profile.is_suspended,
      contact_email: profile.contact_email,
      contact_phone: profile.contact_phone,
      support_email: profile.support_email,
      support_phone: profile.support_phone,
      business_type: profile.business_type,
      business_category: profile.business_category,
      company_registration_number: profile.company_registration_number,
      pan_number: profile.pan_number,
      cin_number: profile.cin_number,
      # KYC Documents
      kyc_documents: kyc_documents
    }
  end
  
  def url_for_document(attachment)
    # For API responses, use service URL which is more reliable
    # This generates a signed URL that expires in 1 hour
    attachment.service_url(expires_in: 1.hour)
  rescue StandardError => e
    Rails.logger.error "Error generating document URL: #{e.message}"
    # If service_url fails, try to generate a direct URL
    Rails.application.routes.url_helpers.url_for(attachment)
  end
end