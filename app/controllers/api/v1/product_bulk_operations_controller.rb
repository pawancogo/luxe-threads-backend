# frozen_string_literal: true

class Api::V1::ProductBulkOperationsController < ApplicationController
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!

  # POST /api/v1/products/bulk_upload
  def bulk_upload
    csv_file = params[:csv_file]
    
    unless csv_file.present?
      render_validation_errors(['CSV file is required'], 'Bulk upload failed')
      return
    end

    # Validate file type
    unless csv_file.content_type == 'text/csv' || 
           csv_file.content_type == 'application/vnd.ms-excel' ||
           csv_file.original_filename&.downcase&.end_with?('.csv')
      render_validation_errors(['File must be a CSV file'], 'Invalid file type')
      return
    end

    # Read CSV content
    csv_content = csv_file.read
    csv_file.rewind if csv_file.respond_to?(:rewind)

    # Import products
    service = Products::BulkImportService.new(current_user.supplier_profile, csv_content)
    result = service.call

    if service.success?
      render_success(
        {
          total: result.results[:total],
          successful: result.results[:successful],
          failed: result.results[:failed],
          products: result.results[:products],
          errors: result.results[:errors]
        },
        'Bulk upload completed successfully'
      )
    else
      render_success(
        {
          total: result.results[:total],
          successful: result.results[:successful],
          failed: result.results[:failed],
          products: result.results[:products],
          errors: result.results[:errors],
          service_errors: result.errors
        },
        'Bulk upload completed with errors'
      )
    end
  rescue StandardError => e
    Rails.logger.error "Bulk upload error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render_error('Bulk upload failed', 'Internal server error')
  end

  # GET /api/v1/products/export
  def export
    supplier_profile = current_user.supplier_profile
    
    products = Product.where(supplier_profile: supplier_profile)
                      .includes(:category, :brand, product_variants: [:product_images, :product_variant_attributes])
    
    service = Products::ExportService.new(products)
    service.call
    
    if service.success?
      send_data service.csv_data,
        type: 'text/csv; charset=utf-8',
        disposition: "attachment; filename=#{service.filename}"
    else
      render_error(service.errors.first || 'Failed to export products', :unprocessable_entity)
    end
  end

  # GET /api/v1/products/export_template
  def export_template
    service = Products::ExportTemplateService.new
    service.call
    
    if service.success?
      send_data service.csv_data,
        type: 'text/csv; charset=utf-8',
        disposition: "attachment; filename=#{service.filename}"
    else
      render_error(service.errors.first || 'Failed to generate template', :unprocessable_entity)
    end
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

end

