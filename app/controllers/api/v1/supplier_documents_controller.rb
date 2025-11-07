# frozen_string_literal: true

class Api::V1::SupplierDocumentsController < ApplicationController
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!
  before_action :set_document, only: [:destroy]

  # GET /api/v1/supplier/documents
  def index
    @profile = current_user.supplier_profile
    documents = @profile.kyc_documents.map do |attachment|
      format_document_data(attachment)
    end
    
    render_success(documents, 'Documents retrieved successfully')
  end

  # POST /api/v1/supplier/documents
  def create
    @profile = current_user.supplier_profile
    
    unless params[:document].present? && params[:document][:file].present?
      render_validation_errors(['Document file is required'], 'Document upload failed')
      return
    end
    
    # Validate file type
    file = params[:document][:file]
    unless valid_document_type?(file)
      render_validation_errors(
        ['Invalid file type. Allowed types: PDF, JPG, PNG (max 10MB)'],
        'Document upload failed'
      )
      return
    end
    
    # Validate file size (10MB max)
    if file.size > 10.megabytes
      render_validation_errors(
        ['File size exceeds 10MB limit'],
        'Document upload failed'
      )
      return
    end
    
    begin
      # Attach the document
      @profile.kyc_documents.attach(file)
      
      # Update verification_documents JSON field for backward compatibility
      attachment = @profile.kyc_documents.last
      add_to_verification_documents_json(attachment)
      
      render_created(format_document_data(attachment), 'Document uploaded successfully')
    rescue StandardError => e
      Rails.logger.error "Document upload failed: #{e.message}"
      render_error('Failed to upload document', 'Internal server error')
    end
  end

  # DELETE /api/v1/supplier/documents/:id
  def destroy
    @profile = current_user.supplier_profile
    
    # Verify the document belongs to this supplier
    unless @profile.kyc_documents.include?(@document)
      render_unauthorized('Document not found or access denied')
      return
    end
    
    @document.purge
    render_no_content('Document deleted successfully')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

  def set_document
    @document = ActiveStorage::Attachment.find_by(id: params[:id])
    unless @document
      render_not_found('Document not found')
    end
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

  def format_document_data(attachment)
    {
      id: attachment.id,
      filename: attachment.filename.to_s,
      content_type: attachment.content_type,
      byte_size: attachment.byte_size,
      url: url_for(attachment),
      created_at: attachment.created_at.iso8601,
      # Human-readable size
      size: ActionController::Base.helpers.number_to_human_size(attachment.byte_size)
    }
  rescue StandardError => e
    Rails.logger.error "Error formatting document: #{e.message}"
    # Fallback format
    {
      id: attachment.id,
      filename: attachment.filename.to_s,
      content_type: attachment.content_type,
      byte_size: attachment.byte_size,
      url: attachment.service_url(expires_in: 1.hour),
      created_at: attachment.created_at.iso8601,
      size: ActionController::Base.helpers.number_to_human_size(attachment.byte_size)
    }
  end

  def add_to_verification_documents_json(attachment)
    docs = @profile.verification_documents_array
    docs << {
      url: attachment.service_url(expires_in: 1.hour),
      filename: attachment.filename.to_s,
      uploaded_at: attachment.created_at.iso8601,
      attachment_id: attachment.id
    }
    @profile.update_column(:verification_documents, docs.to_json)
  rescue StandardError => e
    Rails.logger.error "Error updating verification documents JSON: #{e.message}"
    # Continue without updating JSON field - Active Storage attachment is the source of truth
  end

  def url_for(attachment)
    # For API responses, use service URL which is more reliable
    # This generates a signed URL that expires in 1 hour
    attachment.service_url(expires_in: 1.hour)
  rescue StandardError => e
    Rails.logger.error "Error generating document URL: #{e.message}"
    # If service_url fails, try to generate a direct URL
    Rails.application.routes.url_helpers.url_for(attachment)
  end
end

