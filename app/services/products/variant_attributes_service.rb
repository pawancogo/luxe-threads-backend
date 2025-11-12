# frozen_string_literal: true

# Service for creating/updating product variant attributes
module Products
  class VariantAttributesService < BaseService
    include Products::Concerns::AttributeAssociationHelper

    def initialize(variant, attribute_value_ids)
      super()
      @variant = variant
      @attribute_value_ids = Array(attribute_value_ids).map(&:to_i).reject(&:zero?)
    end

    def call
      return self if @attribute_value_ids.blank?

      with_transaction do
        create_attributes
        set_result(@variant.product_variant_attributes.reload)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_attributes
      create_attribute_associations(
        @variant,
        @attribute_value_ids,
        ProductVariantAttribute,
        :product_variant_id
      )
    end
  end
end

