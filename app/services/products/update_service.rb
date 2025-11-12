# frozen_string_literal: true

# Service for updating products with variants
# Follows Single Responsibility Principle - only handles product update orchestration
module Products
  class UpdateService < BaseService
    attr_reader :product

    def initialize(product, product_params, form_class: ProductForm)
      super()
      @product = product
      @product_params = product_params.dup
      @variants_params = @product_params.delete(:variants_attributes) || []
      @form_class = form_class
    end

    def call
      with_transaction do
        update_product
        update_product_attributes if @product.persisted?
        set_result(@product)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    # Alias for backward compatibility
    def result
      @product || super
    end

    private

    def update_product
      log_execution('update_product', product_id: @product.id)

      form = build_form

      unless form.update(@product)
        add_errors(form.errors.full_messages)
        raise ActiveRecord::RecordInvalid, form.product
      end

      @product.reload
    end

    def update_product_attributes
      return unless @product_params.key?(:attribute_value_ids)

      service = Products::AttributesUpdateService.new(
        @product,
        @product_params[:attribute_value_ids]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to update product attributes'
      end
    end

    def build_form
      form_params = @product_params.merge(
        supplier_profile_id: @product.supplier_profile_id
      )
      form_params[:variants_attributes] = @variants_params if @variants_params.present?
      
      @form_class.new(form_params)
    end
  end
end

