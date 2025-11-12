# frozen_string_literal: true

# Concern for models with JSON fields that need parsing
# Provides helper methods for parsing JSON columns safely
module JsonParseable
  extend ActiveSupport::Concern

  # Parse JSON field as array
  # Usage: parse_json_array(:highlights)
  # Returns: Array or empty array if blank/invalid
  def parse_json_array(field_name)
    value = public_send(field_name)
    return [] if value.blank?
    JSON.parse(value) rescue []
  end

  # Parse JSON field as hash
  # Usage: parse_json_hash(:shipping_zones)
  # Returns: Hash or empty hash if blank/invalid
  def parse_json_hash(field_name)
    value = public_send(field_name)
    return {} if value.blank?
    JSON.parse(value) rescue {}
  end

  # Update JSON field with array
  # Usage: update_json_array(:highlights, ['value1', 'value2'])
  # Note: Uses update! to trigger validations and callbacks
  def update_json_array(field_name, array_value)
    update!(field_name => array_value.to_json)
  end

  # Update JSON field with hash
  # Usage: update_json_hash(:shipping_zones, { key: 'value' })
  # Note: Uses update! to trigger validations and callbacks
  def update_json_hash(field_name, hash_value)
    update!(field_name => hash_value.to_json)
  end

  # Add item to JSON array field
  # Usage: add_to_json_array(:highlights, 'new_value')
  def add_to_json_array(field_name, item)
    array = parse_json_array(field_name)
    array << item
    update_json_array(field_name, array)
  end

  # Remove item from JSON array field
  # Usage: remove_from_json_array(:highlights, 'value')
  def remove_from_json_array(field_name, item)
    array = parse_json_array(field_name)
    array.delete(item)
    update_json_array(field_name, array)
  end

  module ClassMethods
    # Define JSON array parser method
    # Usage: json_array_parser :highlights
    # Creates: highlights_array method
    def json_array_parser(*field_names)
      field_names.each do |field_name|
        method_name = "#{field_name}_array"
        define_method(method_name) do
          parse_json_array(field_name)
        end
      end
    end

    # Define JSON hash parser method
    # Usage: json_hash_parser :shipping_zones
    # Creates: shipping_zones_hash method
    def json_hash_parser(*field_names)
      field_names.each do |field_name|
        method_name = "#{field_name}_hash"
        define_method(method_name) do
          parse_json_hash(field_name)
        end
      end
    end

    # Define JSON list parser method (alias for array, for backward compatibility)
    # Usage: json_list_parser :applicable_categories
    # Creates: applicable_categories_list method
    def json_list_parser(*field_names)
      field_names.each do |field_name|
        method_name = "#{field_name}_list"
        define_method(method_name) do
          parse_json_array(field_name)
        end
      end
    end
  end
end

