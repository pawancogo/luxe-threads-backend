# frozen_string_literal: true

# Service for bulk importing products from CSV
# Handles CSV parsing, validation, and product creation
class ProductBulkImportService
  require 'csv'

  attr_reader :supplier_profile, :csv_content, :errors, :results

  def initialize(supplier_profile, csv_content)
    @supplier_profile = supplier_profile
    @csv_content = csv_content
    @errors = []
    @results = {
      total: 0,
      successful: 0,
      failed: 0,
      products: [],
      errors: []
    }
  end

  def call
    return self unless valid_csv?

    rows = parse_csv
    return self if rows.empty?

    process_rows(rows)
    self
  rescue StandardError => e
    @errors << "Bulk import failed: #{e.message}"
    Rails.logger.error "ProductBulkImportService failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    self
  end

  def success?
    @errors.empty? && @results[:failed] == 0
  end

  private

  def valid_csv?
    if @csv_content.blank?
      @errors << 'CSV content is required'
      return false
    end
    true
  end

  def parse_csv
    rows = []
    begin
      CSV.parse(@csv_content, headers: true, header_converters: :symbol) do |row|
        rows << row.to_h
      end
    rescue CSV::MalformedCSVError => e
      @errors << "Invalid CSV format: #{e.message}"
      return []
    end

    if rows.empty?
      @errors << 'CSV file is empty or has no data rows'
      return []
    end

    rows
  end

  def process_rows(rows)
    @results[:total] = rows.length

    rows.each_with_index do |row, index|
      row_number = index + 2 # +2 because CSV has header row and 0-indexed array
      
      begin
        product_data = build_product_data(row)
        
        if product_data[:errors].any?
          @results[:failed] += 1
          @results[:errors] << {
            row: row_number,
            errors: product_data[:errors],
            data: row
          }
          next
        end

        create_product(product_data, row_number)
      rescue StandardError => e
        @results[:failed] += 1
        @results[:errors] << {
          row: row_number,
          errors: [e.message],
          data: row
        }
        Rails.logger.error "Error processing row #{row_number}: #{e.message}"
      end
    end
  end

  def build_product_data(row)
    errors = []
    product_data = {}

    # Required fields
    product_data[:name] = row[:name]&.strip
    product_data[:description] = row[:description]&.strip
    product_data[:category_id] = find_category_id(row[:category], errors)
    product_data[:brand_id] = find_brand_id(row[:brand], errors)

    # Optional fields
    product_data[:short_description] = row[:short_description]&.strip
    product_data[:website_url] = row[:website_url]&.strip
    product_data[:status] = row[:status]&.strip&.downcase || 'pending'
    product_data[:is_featured] = parse_boolean(row[:is_featured])
    product_data[:is_bestseller] = parse_boolean(row[:is_bestseller])
    product_data[:is_new_arrival] = parse_boolean(row[:is_new_arrival])
    product_data[:is_trending] = parse_boolean(row[:is_trending])

    # Variant data (can have multiple variants per product)
    variant_data = build_variant_data(row, errors)
    product_data[:variants_attributes] = [variant_data] if variant_data

    # Validation
    errors << 'Product name is required' if product_data[:name].blank?
    errors << 'Product description is required' if product_data[:description].blank?
    errors << 'Category is required' if product_data[:category_id].blank?
    errors << 'Brand is required' if product_data[:brand_id].blank?

    { **product_data, errors: errors }
  end

  def build_variant_data(row, errors)
    variant_data = {}

    # Required variant fields
    variant_data[:sku] = row[:sku]&.strip&.presence || generate_sku(row[:name])
    variant_data[:price] = parse_decimal(row[:price], errors, 'Price')
    variant_data[:stock_quantity] = parse_integer(row[:stock_quantity], errors, 'Stock quantity')

    # Optional variant fields
    variant_data[:discounted_price] = parse_decimal(row[:discounted_price], nil, nil)
    variant_data[:mrp] = parse_decimal(row[:mrp], nil, nil)
    variant_data[:weight_kg] = parse_decimal(row[:weight_kg], nil, nil)
    variant_data[:barcode] = row[:barcode]&.strip&.presence

    # Image URLs (comma-separated)
    if row[:image_urls].present?
      variant_data[:image_urls] = row[:image_urls].split(',').map(&:strip).reject(&:blank?)
    end

    # Attributes (comma-separated key:value pairs)
    if row[:attributes].present?
      variant_data[:attributes] = parse_attributes(row[:attributes])
    end

    # Validation
    if variant_data[:price].blank?
      errors << 'Price is required'
      return nil
    end

    if variant_data[:stock_quantity].blank?
      errors << 'Stock quantity is required'
      return nil
    end

    variant_data
  end

  def create_product(product_data, row_number)
    service = ProductCreationService.new(@supplier_profile, product_data.except(:errors))
    result = service.call

    if service.success?
      @results[:successful] += 1
      @results[:products] << {
        row: row_number,
        product_id: service.product.id,
        name: service.product.name,
        sku: service.product.product_variants.first&.sku
      }
    else
      @results[:failed] += 1
      @results[:errors] << {
        row: row_number,
        errors: service.errors,
        data: product_data.except(:errors, :variants_attributes)
      }
    end
  end

  # Helper methods

  def find_category_id(category_name, errors)
    return nil if category_name.blank?

    category = Category.find_by('LOWER(name) = ?', category_name.strip.downcase)
    unless category
      errors << "Category '#{category_name}' not found"
      return nil
    end
    category.id
  end

  def find_brand_id(brand_name, errors)
    return nil if brand_name.blank?

    brand = Brand.find_by('LOWER(name) = ?', brand_name.strip.downcase)
    unless brand
      errors << "Brand '#{brand_name}' not found"
      return nil
    end
    brand.id
  end

  def parse_decimal(value, errors, field_name)
    return nil if value.blank?

    decimal = value.to_s.strip.gsub(/[^0-9.]/, '').to_f
    if decimal <= 0
      errors << "#{field_name} must be greater than 0" if errors
      return nil
    end
    decimal
  end

  def parse_integer(value, errors, field_name)
    return nil if value.blank?

    integer = value.to_s.strip.to_i
    if integer < 0
      errors << "#{field_name} must be non-negative" if errors
      return nil
    end
    integer
  end

  def parse_boolean(value)
    return false if value.blank?
    value.to_s.strip.downcase.in?(%w[true yes 1 y])
  end

  def generate_sku(product_name)
    return nil if product_name.blank?
    base = product_name.parameterize.upcase[0..6]
    "#{base}-#{SecureRandom.alphanumeric(6).upcase}"
  end

  def parse_attributes(attributes_string)
    # Parse "Color:Red,Size:L" format
    attributes = {}
    attributes_string.split(',').each do |pair|
      key, value = pair.split(':').map(&:strip)
      attributes[key] = value if key.present? && value.present?
    end
    attributes
  end
end

