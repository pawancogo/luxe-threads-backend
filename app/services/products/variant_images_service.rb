# frozen_string_literal: true

# Service for creating/updating product variant images
module Products
  class VariantImagesService < BaseService
    def initialize(variant, image_urls)
      super()
      @variant = variant
      @image_urls = Array(image_urls).reject(&:blank?)
    end

    def call
      return self if @image_urls.blank?

      with_transaction do
        create_images
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

