# frozen_string_literal: true

# Service for creating products with variants
# Follows Single Responsibility Principle - only handles product creation orchestration
module Products
  class CreationService < BaseService
    attr_reader :product

    def initialize(supplier_profile, product_params, form_class: ProductForm)
      super()
      @supplier_profile = supplier_profile
      @product_params = product_params.dup
      @variants_params = @product_params.delete(:variants_attributes) || []
      @form_class = form_class
    end

    def call
      with_transaction do
        create_product
        create_product_attributes if @product.persisted?
        create_variants if @product.persisted?
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

    def create_product
      log_execution('create_product', supplier_profile_id: @supplier_profile.id)

      form = build_form

      unless form.save
        add_errors(form.errors.full_messages)
        raise ActiveRecord::RecordInvalid, form.product
      end

      @product = form.product
    end

    def create_product_attributes
      return if @product_params[:attribute_value_ids].blank?

      service = Products::AttributesCreationService.new(
        @product,
        @product_params[:attribute_value_ids]
      )
      service.call

      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to create product attributes'
      end
    end

    def create_variants
      return if @variants_params.blank?

      @variants_params.each do |variant_params|
        variant_service = Products::VariantCreationService.new(@product, variant_params)
        variant_service.call

        unless variant_service.success?
          add_errors(variant_service.errors)
          raise StandardError, "Failed to create variant: #{variant_service.errors.join(', ')}"
        end
      end
    end

    def build_form
      form_params = @product_params.merge(
        supplier_profile_id: @supplier_profile.id
      )
      form_params[:variants_attributes] = @variants_params if @variants_params.present?
      
      @form_class.new(form_params)
    end
  end
end

