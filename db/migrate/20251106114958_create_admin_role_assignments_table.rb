# frozen_string_literal: true

class CreateAdminRoleAssignmentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_role_assignments do |t|
      t.references :admin, null: false, foreign_key: true
      t.references :rbac_role, null: false, foreign_key: true
      
      # Assignment metadata
      t.references :assigned_by, null: true, foreign_key: { to_table: :admins }
      t.datetime :assigned_at, null: false
      t.datetime :expires_at, null: true # For temporary role assignments
      t.boolean :is_active, default: true
      
      # Custom permissions (overrides role permissions)
      t.json :custom_permissions, default: {}
      
      # Timestamps
      t.timestamps
      
      # Indexes
      t.index [:admin_id, :rbac_role_id], unique: true, name: 'index_admin_role_assignments_on_admin_and_role'
      t.index [:admin_id, :is_active]
    end
  end
end

