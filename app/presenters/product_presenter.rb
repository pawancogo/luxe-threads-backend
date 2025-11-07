# frozen_string_literal: true

# Explicitly require ColorHexMap to ensure it's loaded
require_dependency File.join(Rails.root, 'config/initializers/color_hex_map')

# Presenter/Decorator for Product
# Handles presentation logic that doesn't belong in models
class ProductPresenter
  attr_reader :product

  delegate :id, :name, :description, :status, :created_at, :updated_at, to: :product

  def initialize(product)
    @product = product
  end

  # Status presentation
  def status_label
    # Get status value safely
    status_value = product&.status
    return 'Unknown' if status_value.nil?
    
    # Convert to string safely - handle all edge cases
    status_str = begin
      str = status_value.to_s
      str.nil? ? nil : str.strip
    rescue StandardError
      nil
    end
    
    return 'Unknown' if status_str.nil? || status_str.blank? || status_str == 'nil'
    
    # Normalize the status value - handle both integer and string enum values
    normalized_status = case status_str.downcase
    when '0', 'pending'
      'pending'
    when '1', 'active'
      'active'
    when '2', 'rejected'
      'rejected'
    when '3', 'archived'
      'archived'
    else
      status_str.downcase
    end
    
    # Return the human-readable label
    case normalized_status
    when 'active' then 'Active'
    when 'pending' then 'Pending Approval'
    when 'rejected' then 'Rejected'
    when 'archived' then 'Archived'
    else
      # Last resort - try to humanize safely
      # Double-check status_str is not nil before humanizing
      return 'Unknown' if status_str.nil? || status_str.blank?
      
      begin
        humanized = status_str.to_s.humanize
        humanized.present? ? humanized : 'Unknown'
      rescue StandardError, NoMethodError
        'Unknown'
      end
    end
  rescue StandardError => e
    Rails.logger.error "ProductPresenter#status_label error: #{e.message} - #{e.backtrace.first}"
    'Unknown'
  end

  def status_badge_class
    return 'badge-secondary' if product.status.nil?
    
    {
      'active' => 'badge-success',
      'pending' => 'badge-warning',
      'rejected' => 'badge-danger',
      'archived' => 'badge-secondary'
    }[product.status.to_s] || 'badge-secondary'
  end

  # Price presentation
  def price_range
    return 'N/A' if product.product_variants.empty?
    
    prices = product.product_variants.map { |v| v.discounted_price || v.price }.compact
    return 'N/A' if prices.empty?
    
    min_price = prices.min
    max_price = prices.max
    
    if min_price == max_price
      format_price(min_price)
    else
      "#{format_price(min_price)} - #{format_price(max_price)}"
    end
  end

  def min_price
    return 'N/A' if product.product_variants.empty?
    
    prices = product.product_variants.map { |v| v.discounted_price || v.price }.compact
    return 'N/A' if prices.empty?
    
    format_price(prices.min)
  end

  # Stock presentation
  def total_stock
    product.product_variants.sum { |v| v.stock_quantity || 0 }
  end

  def stock_status
    case total_stock
    when 0 then { label: 'Out of Stock', class: 'text-danger' }
    when 1..10 then { label: 'Low Stock', class: 'text-warning' }
    else { label: 'In Stock', class: 'text-success' }
    end
  end

  # Image presentation
  def primary_image_url
    variant = product.product_variants.first
    return nil unless variant
    
    image = variant.product_images.order(:display_order).first
    image&.image_url
  end

  def all_images
    product.product_variants.flat_map do |variant|
      variant.product_images.order(:display_order).map(&:image_url)
    end.compact.uniq
  rescue StandardError
    []
  end

  # Supplier information
  def supplier_name
    product.supplier_profile&.company_name || 'Unknown Supplier'
  end

  def category_name
    product.category&.name || 'Uncategorized'
  end

  def brand_name
    product.brand&.name || 'Unknown Brand'
  end

  # API representation
  def to_api_hash
    {
      id: id,
      name: name,
      slug: product.slug,
      description: description,
      short_description: product.short_description,
      status: status,
      status_label: status_label,
      price_range: price_range,
      min_price: min_price,
      base_price: product.base_price&.to_f,
      base_discounted_price: product.base_discounted_price&.to_f,
      base_mrp: product.base_mrp&.to_f,
      total_stock: total_stock,
      total_stock_quantity: product.total_stock_quantity || 0,
      stock_status: stock_status,
      primary_image_url: primary_image_url,
      images: all_images,
      supplier_name: supplier_name,
      category_name: category_name,
      brand_name: brand_name,
      # Phase 2 fields
      product_type: product.product_type,
      highlights: product.highlights_array,
      search_keywords: product.search_keywords_array,
      tags: product.tags_array,
      is_featured: product.is_featured || false,
      is_bestseller: product.is_bestseller || false,
      is_new_arrival: product.is_new_arrival || false,
      is_trending: product.is_trending || false,
      published_at: product.published_at&.iso8601,
      dimensions: {
        length_cm: product.length_cm&.to_f,
        width_cm: product.width_cm&.to_f,
        height_cm: product.height_cm&.to_f,
        weight_kg: product.weight_kg&.to_f
      },
      attributes: format_product_attributes,
      variants: format_variants,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }
  end
  
  def format_variants
    product.product_variants.map do |variant|
      {
        id: variant.id,
        sku: variant.sku,
        price: variant.price.to_f,
        discounted_price: variant.discounted_price&.to_f,
        mrp: variant.mrp&.to_f,
        cost_price: variant.cost_price&.to_f,
        stock_quantity: variant.stock_quantity || 0,
        reserved_quantity: variant.reserved_quantity || 0,
        available_quantity: variant.available_quantity || 0,
        weight_kg: variant.weight_kg&.to_f,
        currency: variant.currency || 'INR',
        # Phase 2: Inventory flags
        available: variant.available?,
        is_low_stock: variant.is_low_stock || false,
        out_of_stock: variant.out_of_stock || false,
        is_available: variant.is_available || false,
        low_stock_threshold: variant.low_stock_threshold || 10,
        # Phase 2: Identification
        barcode: variant.barcode,
        ean_code: variant.ean_code,
        isbn: variant.isbn,
        current_price: variant.current_price.to_f,
        images: format_variant_images(variant),
        attributes: format_variant_attributes(variant),
        created_at: variant.created_at&.iso8601,
        updated_at: variant.updated_at&.iso8601
      }
    end
  rescue StandardError
    []
  end

  def format_variant_images(variant)
    variant.product_images.order(:display_order).map do |image|
      {
        id: image.id,
        url: image.image_url,
        alt_text: image.alt_text,
        display_order: image.display_order
      }
    end
  end

  def format_product_attributes
    product.product_attributes.includes(attribute_value: :attribute_type).map do |pa|
      {
        attribute_type: pa.attribute_value.attribute_type.name,
        attribute_value: pa.attribute_value.value
      }
    end
  rescue StandardError => e
    Rails.logger.error "Error formatting product attributes: #{e.message}"
    []
  end

  def format_variant_attributes(variant)
    variant.product_variant_attributes.includes(attribute_value: :attribute_type).map do |pva|
      attr_data = {
        attribute_type: pva.attribute_value.attribute_type.name,
        attribute_value: pva.attribute_value.value
      }
      
      # Add color hex code if this is a color attribute
      if pva.attribute_value.attribute_type.name.downcase == 'color'
        hex_code = ColorHexMap.hex_for(pva.attribute_value.value)
        attr_data[:hex_code] = hex_code if hex_code
      end
      
      attr_data
    end
  rescue StandardError => e
    Rails.logger.error "Error formatting variant attributes: #{e.message}"
    []
  end

  private

  def format_price(amount)
    return 'N/A' if amount.nil?
    "$#{amount.to_f.round(2)}"
  end
end

