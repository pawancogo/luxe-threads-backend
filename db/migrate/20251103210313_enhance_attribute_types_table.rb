# Phase 2: Enhance Attribute Types Table
# Adds display configuration, validation rules, and applicability settings
class EnhanceAttributeTypesTable < ActiveRecord::Migration[7.1]
  def up
    # Display configuration
    unless column_exists?(:attribute_types, :display_name)
      add_column :attribute_types, :display_name, :string
    end

    unless column_exists?(:attribute_types, :data_type)
      add_column :attribute_types, :data_type, :string, default: 'string'
      add_index :attribute_types, :data_type unless index_exists?(:attribute_types, :data_type)
    end

    # Variant vs product attribute
    unless column_exists?(:attribute_types, :is_variant_attribute)
      add_column :attribute_types, :is_variant_attribute, :boolean, default: false
      add_index :attribute_types, :is_variant_attribute unless index_exists?(:attribute_types, :is_variant_attribute)
    end

    # Applicability (stored as TEXT for SQLite, JSON array string)
    unless column_exists?(:attribute_types, :applicable_product_types)
      add_column :attribute_types, :applicable_product_types, :text, default: '[]'
    end

    unless column_exists?(:attribute_types, :applicable_categories)
      add_column :attribute_types, :applicable_categories, :text, default: '[]'
    end

    # Display and validation (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:attribute_types, :display_type)
      add_column :attribute_types, :display_type, :string, default: 'select'
    end

    unless column_exists?(:attribute_types, :validation_rules)
      add_column :attribute_types, :validation_rules, :text, default: '{}'
    end

    # Data migration: Set display_name from name if not set
    execute <<-SQL
      UPDATE attribute_types
      SET display_name = name
      WHERE display_name IS NULL OR display_name = '';
    SQL
  end

  def down
    remove_column :attribute_types, :display_name if column_exists?(:attribute_types, :display_name)
    remove_column :attribute_types, :data_type if column_exists?(:attribute_types, :data_type)
    remove_column :attribute_types, :is_variant_attribute if column_exists?(:attribute_types, :is_variant_attribute)
    remove_column :attribute_types, :applicable_product_types if column_exists?(:attribute_types, :applicable_product_types)
    remove_column :attribute_types, :applicable_categories if column_exists?(:attribute_types, :applicable_categories)
    remove_column :attribute_types, :display_type if column_exists?(:attribute_types, :display_type)
    remove_column :attribute_types, :validation_rules if column_exists?(:attribute_types, :validation_rules)
  end
end
