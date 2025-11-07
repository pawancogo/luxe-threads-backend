# frozen_string_literal: true

class CreateRbacRolesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :rbac_roles do |t|
      # Role identification
      t.string :name, null: false, limit: 100
      t.string :slug, null: false, limit: 100
      t.string :role_type, null: false, limit: 50 # 'admin', 'supplier', 'system'
      t.text :description
      
      # Role metadata
      t.boolean :is_system, default: false # System roles cannot be deleted
      t.boolean :is_active, default: true
      t.integer :priority, default: 0 # For role hierarchy (higher = more permissions)
      
      # Permissions metadata (cached for performance)
      t.json :default_permissions, default: {}
      
      # Timestamps
      t.timestamps
      
      # Indexes
      t.index :slug, unique: true
      t.index [:role_type, :is_active]
      t.index :name
    end
  end
end

