# frozen_string_literal: true

class CreateNavigationItems < ActiveRecord::Migration[7.1]
  def change
    create_table :navigation_items do |t|
      # Basic information
      t.string :key, null: false, limit: 100 # Unique identifier (e.g., 'products', 'orders')
      t.string :label, null: false, limit: 100 # Display name (e.g., 'Products', 'Orders')
      t.string :icon, limit: 50 # Font Awesome icon class (e.g., 'fas fa-box')
      t.string :path_method, null: false, limit: 100 # Route helper method (e.g., 'admin_products_path')
      t.string :section, limit: 100 # Section name (e.g., 'Product Management')
      
      # Permissions
      t.text :required_permissions # JSON array of permission slugs (e.g., ['products:view', 'products:read'])
      t.boolean :require_super_admin, default: false
      t.boolean :always_visible, default: false
      
      # Actions (CRUD permissions)
      t.boolean :can_view, default: true
      t.boolean :can_create, default: false
      t.boolean :can_edit, default: false
      t.boolean :can_delete, default: false
      
      # Permissions for actions (JSON)
      t.text :view_permissions # Permission slugs required to view
      t.text :create_permissions # Permission slugs required to create
      t.text :edit_permissions # Permission slugs required to edit
      t.text :delete_permissions # Permission slugs required to delete
      
      # Display settings
      t.integer :display_order, default: 0 # Order within section
      t.boolean :is_active, default: true
      t.boolean :is_system, default: false # System items cannot be deleted
      
      # Metadata
      t.text :description
      t.string :controller_name, limit: 100 # Controller name for active link detection
      
      # Timestamps
      t.timestamps
      
      # Indexes
      t.index :key, unique: true
      t.index [:section, :display_order]
      t.index :is_active
      t.index :is_system
    end
  end
end





