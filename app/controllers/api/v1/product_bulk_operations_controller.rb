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
    service = ProductBulkImportService.new(current_user.supplier_profile, csv_content)
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
    
    products = ProductRepository.new.all_for_supplier_profile(supplier_profile.id)
    
    # Generate CSV
    csv = generate_products_csv(products)
    
    # Send CSV file
    send_data csv,
      type: 'text/csv; charset=utf-8',
      disposition: "attachment; filename=products_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
  end

  # GET /api/v1/products/export_template
  def export_template
    # Generate CSV template with headers and example row
    csv = generate_csv_template
    
    send_data csv,
      type: 'text/csv; charset=utf-8',
      disposition: "attachment; filename=products_import_template.csv"
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

  def generate_products_csv(products)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'name', 'description', 'short_description', 'category', 'brand',
        'status', 'is_featured', 'is_bestseller', 'is_new_arrival', 'is_trending',
        'sku', 'price', 'discounted_price', 'mrp', 'stock_quantity', 'weight_kg',
        'barcode', 'image_urls', 'attributes'
      ]

      # Product rows (one row per variant)
      products.each do |product|
        if product.product_variants.any?
          product.product_variants.each do |variant|
            csv << [
              product.name,
              product.description,
              product.short_description,
              product.category.name,
              product.brand.name,
              product.status,
              product.is_featured ? 'Yes' : 'No',
              product.is_bestseller ? 'Yes' : 'No',
              product.is_new_arrival ? 'Yes' : 'No',
              product.is_trending ? 'Yes' : 'No',
              variant.sku,
              variant.price,
              variant.discounted_price,
              variant.mrp,
              variant.stock_quantity,
              variant.weight_kg,
              variant.barcode,
              variant.product_images.map(&:image_url).join(','),
              format_variant_attributes(variant)
            ]
          end
        else
          # Product without variants
          csv << [
            product.name,
            product.description,
            product.short_description,
            product.category.name,
            product.brand.name,
            product.status,
            product.is_featured ? 'Yes' : 'No',
            product.is_bestseller ? 'Yes' : 'No',
            product.is_new_arrival ? 'Yes' : 'No',
            product.is_trending ? 'Yes' : 'No',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            ''
          ]
        end
      end
    end
  end

  def generate_csv_template
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'name', 'description', 'short_description', 'category', 'brand',
        'status', 'is_featured', 'is_bestseller', 'is_new_arrival', 'is_trending',
        'sku', 'price', 'discounted_price', 'mrp', 'stock_quantity', 'weight_kg',
        'barcode', 'image_urls', 'attributes'
      ]

      # Example row
      csv << [
        'Example Product Name',
        'This is a detailed product description',
        'Short product description',
        'Category Name',
        'Brand Name',
        'pending',
        'No',
        'No',
        'Yes',
        'No',
        'SKU123',
        '99.99',
        '79.99',
        '129.99',
        '100',
        '0.5',
        '1234567890123',
        'https://example.com/image1.jpg,https://example.com/image2.jpg',
        'Color:Red,Size:L'
      ]
    end
  end

  def format_variant_attributes(variant)
    return '' unless variant.respond_to?(:product_variant_attributes) && variant.product_variant_attributes.any?
    
    variant.product_variant_attributes.map do |pva|
      "#{pva.attribute_type.name}:#{pva.attribute_value.value}"
    end.join(',')
  end
end

