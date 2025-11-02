# frozen_string_literal: true

class SeedPredefinedAttributeTypes < ActiveRecord::Migration[7.1]
  def up
    # Load constants - try to load from initializer, fallback to inline definition
    begin
      require_relative '../../config/initializers/attribute_constants'
      definitions = AttributeConstants::ATTRIBUTE_DEFINITIONS
    rescue LoadError, NameError
      # Fallback: define constants inline if initializer not found
      definitions = load_attribute_definitions
    end

    puts "🌱 Seeding predefined attribute types and values..."

    definitions.each do |type_name, values|
      # Find or create attribute type
      attribute_type = AttributeType.find_or_create_by!(name: type_name)
      
      # Create all values for this attribute type
      values.each do |value_name|
        AttributeValue.find_or_create_by!(
          attribute_type: attribute_type,
          value: value_name
        )
      end
      
      puts "  ✓ Created/Updated: #{type_name} (#{values.count} values)"
    end

    puts "✅ Seeded #{AttributeType.count} attribute types with #{AttributeValue.count} total values"
  end

  def down
    # Optional: Remove predefined attributes on rollback
    # This is commented out to preserve data, but can be uncommented if needed
    # begin
    #   require_relative '../../config/initializers/attribute_constants'
    #   AttributeConstants::ATTRIBUTE_DEFINITIONS.keys.each do |type_name|
    #     AttributeType.find_by(name: type_name)&.destroy
    #   end
    # rescue LoadError, NameError
    #   # Skip if constants not found
    # end
  end

  private

  def load_attribute_definitions
    # Fallback definition if initializer not found
    # This is a simplified version - full definitions are in config/initializers/attribute_constants.rb
    {
      'Color' => ['Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple', 'Pink', 'Brown', 'Gray', 'Navy'],
      'Size' => ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      'Fabric' => ['Cotton', 'Polyester', 'Silk', 'Wool', 'Linen', 'Denim', 'Leather'],
      'Material' => ['Leather', 'Canvas', 'Metal', 'Plastic', 'Wood'],
      'Pattern' => ['Solid', 'Striped', 'Polka Dot', 'Floral', 'Geometric'],
      'Fit' => ['Slim Fit', 'Regular Fit', 'Relaxed Fit', 'Loose Fit'],
      'Gender' => ['Men', 'Women', 'Unisex']
    }
  end
end

