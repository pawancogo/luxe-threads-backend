# frozen_string_literal: true

# Custom validator for GST numbers
# Extracts GST validation logic from SupplierProfile model
class GstNumberValidator < ActiveModel::EachValidator
  GST_PATTERN = /\A[A-Z0-9]{10,15}\z/.freeze
  TEMP_PREFIX = 'GST'.freeze

  def validate_each(record, attribute, value)
    return if value.blank?
    
    # Allow temporary GST numbers (auto-generated)
    return if temporary_gst?(value)

    unless value.match?(GST_PATTERN)
      record.errors.add(attribute, 'must be a valid GST number format (10-15 alphanumeric characters)')
    end
  end

  private

  def temporary_gst?(value)
    value.start_with?(TEMP_PREFIX) && value.length > 10
  end
end

