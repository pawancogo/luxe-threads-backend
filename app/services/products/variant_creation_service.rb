# frozen_string_literal: true

# Service for creating product variants
module Products
  class VariantCreationService < BaseService
    attr_reader :variant

    def initialize(product, variant_params, form_class: ProductVariantForm)
      super()
      @product = product
      @variant_params = variant_params.dup
      @form_class = form_class
    end

    def call
      with_transaction do
        create_variant
        create_variant_images if @variant.persisted?
        create_variant_attributes if @variant.persisted?
        set_result(@variant)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    # Alias for backward compatibility
    def result
      @variant || super
    end

    private

    def create_variant
      log_execution('create_variant', product_id: @product.id)

      form = build_form

      unless form.save
        add_errors(form.errors.full_messages)
        raise ActiveRecord::RecordInvalid, form.variant
      end

      @variant = form.variant
    end

    def create_variant_images
      return if @variant_params[:image_urls].blank?

      service = Products::VariantImagesService.new(
        @variant,
        @variant_params[:image_urls]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to create variant images'
      end
    end

    def create_variant_attributes
      return if @variant_params[:attribute_value_ids].blank?

      service = Products::VariantAttributesService.new(
        @variant,
        @variant_params[:attribute_value_ids]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to create variant attributes'
      end
    end

    def build_form
      form_params = @variant_params.merge(product_id: @product.id)
      @form_class.new(form_params)
    end
  end
end

