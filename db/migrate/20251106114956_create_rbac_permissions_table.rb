# frozen_string_literal: true

class CreateRbacPermissionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :rbac_permissions do |t|
      # Permission identification
      t.string :name, null: false, limit: 100
      t.string :slug, null: false, limit: 100
      t.string :resource_type, null: false, limit: 50 # 'product', 'order', 'user', 'supplier', etc.
      t.string :action, null: false, limit: 50 # 'create', 'read', 'update', 'delete', 'manage', 'view', etc.
      
      # Permission metadata
      t.text :description
      t.string :category, limit: 50 # 'product', 'order', 'user', 'admin', 'supplier', etc.
      t.boolean :is_system, default: false # System permissions cannot be deleted
      t.boolean :is_active, default: true
      
      # Timestamps
      t.timestamps
      
      # Indexes
      t.index :slug, unique: true
      t.index [:resource_type, :action]
      t.index :category
      t.index [:category, :is_active]
    end
  end
end

