# frozen_string_literal: true

# Base serializer with modern Rails patterns
# Supports passing options/params and nested serializers
# Updated from vendor-backend patterns to use modern Ruby/Rails conventions
class BaseSerializer
  attr_reader :object, :options

  # Initialize with object and options hash
  # Options can be passed through to nested serializers
  def initialize(object, options = {})
    @object = object
    @options = options.is_a?(Hash) ? options.with_indifferent_access : {}
  end

  # Serialize single object
  def as_json(*_args)
    attributes
  end

  # Serialize collection - modern pattern
  def self.collection(collection, **options)
    collection.map { |item| new(item, options).as_json }
  end

  # Serialize many (alias for collection)
  def self.many(objects = [], **options)
    collection(objects, **options)
  end

  protected

  # Override in subclasses - call super, then add custom fields
  def attributes
    result = {}
    
    # Get defined attributes from class
    self.class.defined_attributes.each do |attr|
      result[attr] = object.public_send(attr) if object.respond_to?(attr)
    end
    
    # Add associations (belongs_to, has_one, has_many)
    # Supports conditional serialization with `if:` option
    self.class.defined_associations.each do |assoc|
      # Check if association should be included (conditional serialization)
      if assoc[:options][:if]
        condition_method = "#{assoc[:name]}_loaded?"
        should_include = respond_to?(condition_method, true) ? send(condition_method) : true
        next unless should_include
      end
      
      # Merge parent options with association-specific serializer_options
      assoc_serializer_options = assoc[:options][:serializer_options] || {}
      merged_assoc_options = self.options.merge(assoc_serializer_options)
      
      result[assoc[:name]] = serialize_association(
        assoc[:name], 
        assoc[:serializer], 
        merged_assoc_options
      )
    end
    
    result
  end

  # Helper methods
  def format_date(date)
    date&.iso8601
  end

  def format_price(amount)
    amount&.to_f
  end

  def format_boolean(value)
    !!value
  end

  # Serialize association - modern pattern with option merging
  # Supports passing options/params to nested serializers
  # Options are automatically passed through to nested serializers
  def serialize_association(association_name, serializer_class, assoc_options = {})
    return nil unless object.respond_to?(association_name)
    
    # Options are already merged in the calling code
    # This ensures nested serializers receive the parent's options plus any association-specific options
    merged_options = assoc_options.with_indifferent_access
    
    association = object.public_send(association_name)
    return nil if association.blank?
    return [] if association.respond_to?(:each) && association.empty?

    # Pass options to nested serializers - they can access via options method
    if association.respond_to?(:each)
      association.map { |item| serializer_class.new(item, merged_options).as_json }
    else
      serializer_class.new(association, merged_options).as_json
    end
  end

  # Deep merge options to preserve nested option structures
  def deep_merge_options(parent, child)
    parent.merge(child) do |_key, old_val, new_val|
      if old_val.is_a?(Hash) && new_val.is_a?(Hash)
        old_val.deep_merge(new_val)
      else
        new_val
      end
    end
  end

  # Class methods for defining attributes
  def self.attributes(*attrs)
    @defined_attributes ||= []
    @defined_attributes.concat(attrs.map(&:to_sym))
    @defined_attributes.uniq!
  end

  def self.defined_attributes
    @defined_attributes ||= []
  end

  # Class methods for associations - modern pattern with keyword arguments
  # Supports conditional serialization with `if:` option
  # Supports passing options to nested serializers via `serializer_options:` parameter
  # Example: has_one :address, serializer: AddressSerializer, serializer_options: { include_user: true }
  def self.belongs_to(association_name, serializer: nil, if: nil, serializer_options: {}, **options)
    add_association(association_name, serializer, options.merge(
      if: binding.local_variable_get(:if),
      serializer_options: serializer_options
    ))
  end

  def self.has_one(association_name, serializer: nil, if: nil, serializer_options: {}, **options)
    add_association(association_name, serializer, options.merge(
      if: binding.local_variable_get(:if),
      serializer_options: serializer_options
    ))
  end

  def self.has_many(association_name, serializer: nil, if: nil, serializer_options: {}, **options)
    add_association(association_name, serializer, options.merge(
      if: binding.local_variable_get(:if),
      serializer_options: serializer_options
    ))
  end

  def self.defined_associations
    @defined_associations ||= []
  end

  private

  def self.add_association(name, serializer_class, options)
    @defined_associations ||= []
    @defined_associations << {
      name: name.to_sym,
      serializer: serializer_class,
      options: options
    }
  end
end

