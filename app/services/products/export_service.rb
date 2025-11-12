# frozen_string_literal: true

# Service for exporting products to CSV
module Products
  class ExportService < BaseService
    include Products::Concerns::ProductCsvHeaders
    
    require 'csv'

    attr_reader :csv_data

    def initialize(products_scope)
      super()
      @products_scope = products_scope
    end

    def call
      generate_csv
      set_result(@csv_data)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    def filename
      "products_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    end

    private

    def generate_csv
      @csv_data = CSV.generate(headers: true) do |csv|
        csv << csv_headers

        @products_scope.each do |product|
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
              '', '', '', '', '', '', '', ''
            ]
          end
        end
      end
    end

    def format_variant_attributes(variant)
      return '' unless variant.respond_to?(:product_variant_attributes) && variant.product_variant_attributes.any?
      
      variant.product_variant_attributes.map do |pva|
        "#{pva.attribute_type.name}:#{pva.attribute_value.value}"
      end.join(',')
    end
  end
end

