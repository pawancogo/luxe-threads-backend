# frozen_string_literal: true

class Api::V1::SupplierDocumentsController < ApplicationController
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!
  before_action :set_document, only: [:destroy]

  # GET /api/v1/supplier/documents
  def index
    @profile = current_user.supplier_profile
    documents = @profile.kyc_documents.map do |attachment|
      SupplierDocumentSerializer.new(attachment).as_json
    end
    
    render_success(documents, 'Documents retrieved successfully')
  end

  # POST /api/v1/supplier/documents
  def create
    @profile = current_user.supplier_profile
    
    file = params[:document]&.dig(:file)
    
    service = Suppliers::DocumentUploadService.new(@profile, file)
    service.call
    
    if service.success?
      render_created(
        SupplierDocumentSerializer.new(service.attachment).as_json,
        'Document uploaded successfully'
      )
    else
      render_validation_errors(service.errors, 'Document upload failed')
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

end

