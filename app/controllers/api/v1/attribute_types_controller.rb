# frozen_string_literal: true

# Explicitly require ColorHexMap to ensure it's loaded
require_dependency File.join(Rails.root, 'config/initializers/color_hex_map')

# Controller for managing attribute types and values
# Used by suppliers to manage product attributes like Color, Size, Fabric, etc.
# Public read access for customers, authenticated write access for suppliers
class Api::V1::AttributeTypesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]
  # Note: authorize_supplier! callback removed since create/update/destroy actions don't exist
  # The route only allows :index, which is public (no authentication required)

  # GET /api/v1/attribute_types
  # Get all attribute types with their values
  # Optional query params:
  #   level=product|variant to filter by level
  #   category_id=123 to filter Size values by category
  def index
    level = params[:level]&.to_sym # :product or :variant
    category_id = params[:category_id]&.to_i
    
    # Get category for size filtering
    category = Category.find_by(id: category_id) if category_id
    
    service = AttributeTypesIndexService.new(level: level, category_id: category_id)
    service.call
    
    if service.success?
      serializer_options = { category: category }.compact
      serialized_data = service.attribute_types.map do |attr_type|
        AttributeTypeSerializer.new(attr_type, serializer_options).as_json
      end
      
      render_success(serialized_data, 'Attribute types retrieved successfully')
    else
      render_error(service.errors.first || 'Failed to retrieve attribute types', :unprocessable_entity)
    end
  end

  private

  def authorize_supplier!
    unless current_user
      render_unauthorized('Authentication required')
      return
    end
    
    # Check if user is a supplier (has supplier role or supplier_profile)
    is_supplier = current_user.supplier? || 
                  current_user.supplier_profile.present?
    
    unless is_supplier
      Rails.logger.warn "User #{current_user.id} (#{current_user.role}) attempted to access attribute_types API"
      render_unauthorized('Supplier access required')
      return
    end
  end
end


