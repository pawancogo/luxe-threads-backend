# frozen_string_literal: true

# Service for creating product-level attributes
module Products
  class AttributesCreationService < BaseService
    include Products::Concerns::AttributeAssociationHelper

    def initialize(product, attribute_value_ids)
      super()
      @product = product
      @attribute_value_ids = Array(attribute_value_ids).map(&:to_i).reject(&:zero?)
    end

    def call
      return self if @attribute_value_ids.blank?

      with_transaction do
        create_attributes
        set_result(@product.product_attributes.reload)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_attributes
      create_attribute_associations(
        @product,
        @attribute_value_ids,
        ProductAttribute,
        :product_id
      )
    end
  end
end

