# frozen_string_literal: true

# Service for fetching and formatting attribute types with their values
class AttributeTypesIndexService < BaseService
  attr_reader :attribute_types

  def initialize(level: nil, category_id: nil)
    super()
    @level = level&.to_sym
    @category_id = category_id
  end

  def call
    fetch_attribute_types
    ensure_predefined_values
    set_result(@attribute_types)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def fetch_attribute_types
    @attribute_types = AttributeType.includes(:attribute_values).order(:name)
    
    # Filter by level if specified
    if @level && AttributeConstants::ATTRIBUTE_LEVELS.key?(@level)
      allowed_types = AttributeConstants::ATTRIBUTE_LEVELS[@level]
      @attribute_types = @attribute_types.where(name: allowed_types)
    elsif @level
      # If level is specified but not in ATTRIBUTE_LEVELS, return empty
      @attribute_types = @attribute_types.none
    end
  end

  def ensure_predefined_values
    @attribute_types.each do |attr_type|
      if attr_type.predefined? && attr_type.attribute_values.empty?
        attr_type.ensure_predefined_values!
        attr_type.reload
      end
    end
  end
end

