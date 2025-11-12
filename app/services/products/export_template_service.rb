# frozen_string_literal: true

# Service for generating product import CSV template
module Products
  class ExportTemplateService < BaseService
    include Products::Concerns::ProductCsvHeaders
    
    require 'csv'

    attr_reader :csv_data

    def initialize
      super()
    end

    def call
      generate_template
      set_result(@csv_data)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    def filename
      'products_import_template.csv'
    end

    private

    def generate_template
      @csv_data = CSV.generate(headers: true) do |csv|
        csv << csv_headers

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
  end
end

