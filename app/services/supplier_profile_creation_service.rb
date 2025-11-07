# frozen_string_literal: true

# Service for creating supplier profiles
# Extracted from User model callback
class SupplierProfileCreationService
  attr_reader :user, :options

  def initialize(user, options = {})
    @user = user
    @options = options
  end

  def call
    return user.supplier_profile if user.supplier_profile.present?
    return nil unless should_create?

    profile = user.create_supplier_profile!(profile_attributes)
    # Reload user to ensure association is available
    user.reload
    profile
  rescue StandardError => e
    Rails.logger.error "SupplierProfileCreationService failed for user #{user.id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e # Re-raise to be caught by calling service
  end

  private

  def should_create?
    user.role == 'supplier' || options[:force] == true
  end

  def profile_attributes
    {
      owner_id: user.id, # Phase 1: Set owner_id instead of supplier_id
      user_id: user.id, # Legacy field for backward compatibility
      company_name: options[:company_name] || default_company_name,
      gst_number: options[:gst_number] || generate_gst_number,
      description: options[:description] || default_description,
      verified: options[:verified] || false
    }
  end

  def default_company_name
    "#{user.first_name} #{user.last_name} - Company"
  end

  def generate_gst_number
    "GST#{user.id}#{Time.now.to_i.to_s.last(6)}"
  end

  def default_description
    "Supplier profile - please complete your company details"
  end
end

