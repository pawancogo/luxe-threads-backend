# frozen_string_literal: true

# Serializer for Supplier Document API responses
class SupplierDocumentSerializer < BaseSerializer
  attributes :id, :filename, :content_type, :byte_size, :url, :created_at, :size

  def url
    begin
      # For API responses, use service URL which is more reliable
      # This generates a signed URL that expires in 1 hour
      object.service_url(expires_in: 1.hour)
    rescue StandardError => e
      Rails.logger.error "Error generating document URL: #{e.message}"
      # If service_url fails, try to generate a direct URL
      Rails.application.routes.url_helpers.url_for(object)
    end
  end

  def size
    ActionController::Base.helpers.number_to_human_size(object.byte_size)
  end
end

