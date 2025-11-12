# frozen_string_literal: true

# Serializer for admin supplier API responses
class AdminSupplierSerializer < BaseSerializer
  attributes :id, :email, :first_name, :last_name, :full_name, :phone_number,
             :company_name, :verified, :is_active, :created_at, :gst_number,
             :description, :website_url, :supplier_tier, :deleted_at, :updated_at

  def company_name
    profile&.company_name
  end

  def verified
    profile&.verified || false
  end

  def is_active
    object.deleted_at.nil?
  end

  def gst_number
    profile&.gst_number
  end

  def description
    profile&.description
  end

  def website_url
    profile&.website_url
  end

  def supplier_tier
    profile&.supplier_tier
  end

  def deleted_at
    object.deleted_at
  end

  def updated_at
    object.updated_at
  end

  private

  def profile
    @profile ||= object.primary_supplier_profile || object.supplier_profile
  end
end

