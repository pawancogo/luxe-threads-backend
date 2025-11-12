# frozen_string_literal: true

# Service for updating product variants
# Follows Single Responsibility Principle - only handles variant update orchestration
module Products
  class VariantUpdateService < BaseService
    attr_reader :variant

    def initialize(variant, variant_params, form_class: ProductVariantForm)
      super()
      @variant = variant
      @variant_params = variant_params.dup
      @form_class = form_class
    end

    def call
      with_transaction do
        update_variant
        update_variant_images if @variant.persisted?
        update_variant_attributes if @variant.persisted?
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

    def update_variant
      log_execution('update_variant', variant_id: @variant.id)

      form = build_form

      unless form.update(@variant)
        add_errors(form.errors.full_messages)
        raise ActiveRecord::RecordInvalid, form.variant
      end

      @variant.reload
    end

    def update_variant_images
      return unless @variant_params.key?(:image_urls)

      # Remove old images
      @variant.product_images.destroy_all

      # Create new images
      return if @variant_params[:image_urls].blank?

      service = Products::VariantImagesService.new(
        @variant,
        @variant_params[:image_urls]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to update variant images'
      end
    end

    def update_variant_attributes
      return unless @variant_params.key?(:attribute_value_ids)

      # Remove old attributes
      @variant.product_variant_attributes.destroy_all

      # Create new attributes
      return if @variant_params[:attribute_value_ids].blank?

      service = Products::VariantAttributesService.new(
        @variant,
        @variant_params[:attribute_value_ids]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to update variant attributes'
      end
    end

    def build_form
      form_params = @variant_params.merge(product_id: @variant.product_id)
      @form_class.new(form_params)
    end
  end
end

