# frozen_string_literal: true

# Service for updating product-level attributes
module Products
  class AttributesUpdateService < BaseService
    include Products::Concerns::AttributeAssociationHelper

    def initialize(product, attribute_value_ids)
      super()
      @product = product
      @attribute_value_ids = Array(attribute_value_ids).map(&:to_i).reject(&:zero?)
    end

    def call
      with_transaction do
        update_attributes
        set_result(@product.product_attributes.reload)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_attributes
      # Remove old product-level attributes
      @product.product_attributes.destroy_all

      # Create new product-level attributes
      create_attribute_associations(
        @product,
        @attribute_value_ids,
        ProductAttribute,
        :product_id
      )
    end
  end
end

