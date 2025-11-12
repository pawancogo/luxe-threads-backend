# frozen_string_literal: true

# Helper concern for creating attribute associations
# DRY: Shared logic for ProductAttribute and ProductVariantAttribute creation
module Products
  module Concerns
    module AttributeAssociationHelper
      extend ActiveSupport::Concern

      private

      # Create attribute associations for a record
      # @param record [Product, ProductVariant] The record to associate attributes with
      # @param attribute_value_ids [Array<Integer>] Array of attribute value IDs
      # @param association_class [Class] The association class (ProductAttribute or ProductVariantAttribute)
      # @param foreign_key [Symbol] The foreign key field name (:product_id or :product_variant_id)
      def create_attribute_associations(record, attribute_value_ids, association_class, foreign_key)
        attribute_value_ids.each do |attribute_value_id|
          next unless AttributeValue.exists?(attribute_value_id)

          attribute_value = AttributeValue.find(attribute_value_id)
          
          # Validate attribute level based on association class
          if association_class == ProductAttribute
            next unless AttributeConstants.product_level?(attribute_value.attribute_type.name)
          end

          association_class.find_or_create_by!(
            foreign_key => record.id,
            attribute_value_id: attribute_value_id
          )
        end
      end
    end
  end
end

