# Phase 2: Enhance Attribute Values Table
# Adds display configuration and metadata
class EnhanceAttributeValuesTable < ActiveRecord::Migration[7.1]
  def up
    # Display configuration
    unless column_exists?(:attribute_values, :display_value)
      add_column :attribute_values, :display_value, :string
    end

    unless column_exists?(:attribute_values, :display_order)
      add_column :attribute_values, :display_order, :integer, default: 0
      add_index :attribute_values, [:attribute_type_id, :display_order] unless index_exists?(:attribute_values, [:attribute_type_id, :display_order])
    end

    # Metadata (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:attribute_values, :metadata)
      add_column :attribute_values, :metadata, :text, default: '{}'
    end

    # Data migration: Set display_value from value if not set
    execute <<-SQL
      UPDATE attribute_values
      SET display_value = value
      WHERE display_value IS NULL OR display_value = '';
    SQL
  end

  def down
    remove_column :attribute_values, :display_value if column_exists?(:attribute_values, :display_value)
    remove_column :attribute_values, :display_order if column_exists?(:attribute_values, :display_order)
    remove_column :attribute_values, :metadata if column_exists?(:attribute_values, :metadata)
  end
end
