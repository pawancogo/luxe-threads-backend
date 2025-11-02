# frozen_string_literal: true

# Service for generating SKU codes
# Extracted from ProductVariant model callback
class SkuGenerationService
  MAX_ATTEMPTS = 100

  def self.generate_for(product_variant)
    new(product_variant).generate
  end

  def initialize(product_variant)
    @product_variant = product_variant
    @product = product_variant.product
  end

  def generate
    base_sku = build_base_sku
    unique_sku = ensure_uniqueness(base_sku)
    unique_sku
  end

  private

  def build_base_sku
    product_code = generate_product_code
    variant_number = SecureRandom.alphanumeric(6).upcase
    "#{product_code}-#{variant_number}"
  end

  def generate_product_code
    return 'PROD' if @product.name.blank?
    
    product_name = @product.name.to_s.parameterize.upcase
    product_code = product_name[0..6]
    product_code.present? ? product_code : 'PROD'
  end

  def ensure_uniqueness(base_sku)
    sku = base_sku
    counter = 1

    while ProductVariant.exists?(sku: sku) && counter <= MAX_ATTEMPTS
      sku = "#{base_sku}-#{counter}"
      counter += 1
    end

    if counter > MAX_ATTEMPTS
      Rails.logger.error "Failed to generate unique SKU for product #{@product.id} after #{MAX_ATTEMPTS} attempts"
      raise StandardError, 'Failed to generate unique SKU'
    end

    sku
  end
end

