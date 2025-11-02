# frozen_string_literal: true

# Explicitly require ColorHexMap to ensure it's loaded
require_dependency File.join(Rails.root, 'config/initializers/color_hex_map')

# Controller for managing attribute types and values
# Used by suppliers to manage product attributes like Color, Size, Fabric, etc.
class Api::V1::AttributeTypesController < ApplicationController
  before_action :authorize_supplier!

  # GET /api/v1/attribute_types
  # Get all attribute types with their values
  # Optional query params:
  #   level=product|variant to filter by level
  #   category_id=123 to filter Size values by category
  def index
    level = params[:level]&.to_sym # :product or :variant
    category_id = params[:category_id]&.to_i
    
    attribute_types = AttributeType.includes(:attribute_values).order(:name)
    
    # Filter by level if specified
    if level && AttributeConstants::ATTRIBUTE_LEVELS.key?(level)
      allowed_types = AttributeConstants::ATTRIBUTE_LEVELS[level]
      attribute_types = attribute_types.where(name: allowed_types)
    end
    
    # Get category for size filtering
    category = Category.find_by(id: category_id) if category_id
    
    formatted_data = attribute_types.map do |attr_type|
      is_color_type = attr_type.name.downcase == 'color'
      is_size_type = attr_type.name.downcase == 'size'
      is_product_level = AttributeConstants.product_level?(attr_type.name)
      is_variant_level = AttributeConstants.variant_level?(attr_type.name)
      
      # Get values - filter Size values by category if category provided
      values = if is_size_type && category
        # Filter size values by category
        category_size_values = AttributeConstants.size_values_for_category(category.name)
        attr_type.attribute_values.where(value: category_size_values).order(:value)
      else
        attr_type.attribute_values.order(:value)
      end
      
      {
        id: attr_type.id,
        name: attr_type.name,
        level: is_product_level ? 'product' : (is_variant_level ? 'variant' : nil),
        values: values.map do |value|
          value_data = {
            id: value.id,
            value: value.value
          }
          
          # Add color hex code if this is a color attribute type
          if is_color_type
            hex_code = ColorHexMap.hex_for(value.value)
            value_data[:hex_code] = hex_code if hex_code
          end
          
          value_data
        end
      }
    end
    
    render_success(formatted_data, 'Attribute types retrieved successfully')
  end

  private

  def authorize_supplier!
    unless current_user
      render_unauthorized('Authentication required')
      return
    end
    
    # Check if user is a supplier (has supplier role or supplier_profile)
    is_supplier = current_user.supplier_profile.present? || 
                  current_user.role&.downcase&.include?('supplier') ||
                  current_user.role == 'supplier' ||
                  current_user.role == 'verified_supplier' ||
                  current_user.role == 'premium_supplier' ||
                  current_user.role == 'partner_supplier'
    
    unless is_supplier
      Rails.logger.warn "User #{current_user.id} (#{current_user.role}) attempted to access attribute_types API"
      render_unauthorized('Supplier access required')
      return
    end
  end
end

