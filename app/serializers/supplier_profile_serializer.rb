# frozen_string_literal: true

# Serializer for SupplierProfile API responses
class SupplierProfileSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      company_name: object.company_name,
      gst_number: object.gst_number,
      description: object.description,
      website_url: object.website_url,
      contact_email: object.contact_email,
      contact_phone: object.contact_phone,
      support_email: object.support_email,
      support_phone: object.support_phone,
      business_type: object.business_type,
      business_category: object.business_category,
      company_registration_number: object.company_registration_number,
      pan_number: object.pan_number,
      cin_number: object.cin_number,
      supplier_tier: object.supplier_tier,
      verified: format_boolean(object.verified),
      is_active: format_boolean(object.is_active),
      is_suspended: format_boolean(object.is_suspended),
      created_at: format_date(object.created_at),
      updated_at: format_date(object.updated_at)
    }
  end
end

