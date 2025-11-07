# frozen_string_literal: true

# Eager Loading Concern
# Provides standardized eager loading patterns to prevent N+1 queries
# Follows DRY principle
module EagerLoading
  extend ActiveSupport::Concern

  class_methods do
    # Define default eager loading associations for a controller
    def default_includes(*associations)
      @default_includes = associations
    end

    def get_default_includes
      @default_includes || []
    end
  end

  protected

  # Apply eager loading to a scope
  def with_eager_loading(scope, additional_includes: [])
    includes_to_apply = self.class.get_default_includes + Array(additional_includes)
    
    if includes_to_apply.any?
      scope.includes(*includes_to_apply)
    else
      scope
    end
  end

  # Common eager loading patterns
  def product_includes
    [
      :brand,
      :category,
      :supplier_profile,
      product_variants: [
        :product_images,
        :product_variant_attributes,
        attribute_values: :attribute_type
      ],
      product_attributes: { attribute_value: :attribute_type }
    ]
  end

  def order_includes
    [
      :user,
      :shipping_address,
      :billing_address,
      order_items: {
        product_variant: {
          product: [:brand, :category, product_variants: :product_images]
        },
        supplier_profile: :owner
      }
    ]
  end

  def user_includes
    [
      :supplier_profile,
      :addresses,
      supplier_profile: :owner
    ]
  end

  def review_includes
    [
      :user,
      :product,
      product: [:brand, :category]
    ]
  end

  def return_request_includes
    [
      :user,
      :order,
      return_items: {
        order_item: {
          product_variant: {
            product: [:brand, :category]
          }
        }
      }
    ]
  end
end

