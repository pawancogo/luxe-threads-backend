# frozen_string_literal: true

class CreateSystemConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :system_configurations do |t|
      t.string :key, null: false, index: { unique: true }
      t.text :value
      t.string :value_type, default: 'string', null: false # string, integer, float, boolean, json
      t.string :category, default: 'general' # general, payment, shipping, email, api, feature_flags, etc.
      t.text :description
      t.boolean :is_active, default: true, null: false
      t.references :created_by, polymorphic: true, null: true, index: true
      
      t.timestamps
    end

    add_index :system_configurations, :category
    add_index :system_configurations, :is_active
  end
end

