# frozen_string_literal: true

# Service for updating product variant images (replaces old ones)
module Products
  class VariantImagesUpdateService < BaseService
    def initialize(variant, image_urls)
      super()
      @variant = variant
      @image_urls = Array(image_urls).reject(&:blank?)
    end

    def call
      with_transaction do
        # Remove old images
        @variant.product_images.destroy_all

        # Create new images
        create_images unless @image_urls.blank?
        set_result(@variant.product_images.reload)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_images
      @image_urls.each_with_index do |url, index|
        next if url.blank?

        ProductImage.create!(
          product_variant_id: @variant.id,
          image_url: url,
          display_order: index,
          alt_text: "#{@variant.product.name} - Image #{index + 1}"
        )
      end
    end
  end
end

