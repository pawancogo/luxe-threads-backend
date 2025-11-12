# frozen_string_literal: true

# Concern for models with supplier-related roles and capabilities
# Extracts supplier role checking logic
module SupplierRoleable
  extend ActiveSupport::Concern

  # Check if user is a supplier (has supplier_profile)
  def supplier?
    supplier_profile.present? || role == 'supplier'
  end

  # Check if user owns a supplier profile
  def supplier_owner?
    owned_supplier_profiles.exists?
  end

  # Get primary supplier profile (owned or associated)
  def primary_supplier_profile
    owned_supplier_profiles.first || supplier_profile
  end

  # Check if user is part of a supplier account
  def supplier_account_member?
    supplier_account_users.exists?
  end
end

