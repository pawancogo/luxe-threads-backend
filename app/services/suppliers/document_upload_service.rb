# frozen_string_literal: true

# Service for uploading supplier documents
module Suppliers
  class DocumentUploadService < BaseService
    attr_reader :attachment

    def initialize(supplier_profile, file)
      super()
      @supplier_profile = supplier_profile
      @file = file
    end

    def call
      validate_file!
      upload_document
      update_verification_documents_json
      set_result(@attachment)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_file!
      unless @file.present?
        add_error('Document file is required')
        raise StandardError, 'Document file is required'
      end

      unless valid_document_type?(@file)
        add_error('Invalid file type. Allowed types: PDF, JPG, PNG (max 10MB)')
        raise StandardError, 'Invalid file type'
      end

      if @file.size > 10.megabytes
        add_error('File size exceeds 10MB limit')
        raise StandardError, 'File size exceeds limit'
      end
    end

    def upload_document
      @supplier_profile.kyc_documents.attach(@file)
      @attachment = @supplier_profile.kyc_documents.last
      
      unless @attachment
        add_error('Failed to attach document')
        raise StandardError, 'Failed to attach document'
      end
    end

    def update_verification_documents_json
      docs = @supplier_profile.verification_documents_array
      docs << {
        url: @attachment.service_url(expires_in: 1.hour),
        filename: @attachment.filename.to_s,
        uploaded_at: @attachment.created_at.iso8601,
        attachment_id: @attachment.id
      }
      # Use update! to trigger validations and callbacks
      @supplier_profile.update!(verification_documents: docs.to_json)
    rescue StandardError => e
      Rails.logger.error "Error updating verification documents JSON: #{e.message}"
      # Continue without updating JSON field - Active Storage attachment is the source of truth
    end

    def valid_document_type?(file)
      return false unless file.respond_to?(:content_type)
      
      allowed_types = [
        'application/pdf',
        'image/jpeg',
        'image/jpg',
        'image/png'
      ]
      
      allowed_types.include?(file.content_type)
    end
  end
end

