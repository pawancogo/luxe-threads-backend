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

    user.create_supplier_profile!(profile_attributes)
  rescue StandardError => e
    Rails.logger.error "SupplierProfileCreationService failed for user #{user.id}: #{e.message}"
    nil
  end

  private

  def should_create?
    user.role == 'supplier' || options[:force] == true
  end

  def profile_attributes
    {
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

