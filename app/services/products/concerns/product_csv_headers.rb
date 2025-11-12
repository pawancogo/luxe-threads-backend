# frozen_string_literal: true

# Concern for product CSV export headers
# DRY: Shared headers between template and export services
module Products
  module Concerns
    module ProductCsvHeaders
      extend ActiveSupport::Concern

      PRODUCT_CSV_HEADERS = [
        'name', 'description', 'short_description', 'category', 'brand',
        'status', 'is_featured', 'is_bestseller', 'is_new_arrival', 'is_trending',
        'sku', 'price', 'discounted_price', 'mrp', 'stock_quantity', 'weight_kg',
        'barcode', 'image_urls', 'attributes'
      ].freeze

      included do
        def csv_headers
          PRODUCT_CSV_HEADERS
        end
      end
    end
  end
end

