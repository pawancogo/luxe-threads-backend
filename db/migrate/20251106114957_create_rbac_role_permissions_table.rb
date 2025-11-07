# frozen_string_literal: true

class CreateRbacRolePermissionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :rbac_role_permissions do |t|
      t.references :rbac_role, null: false, foreign_key: true
      t.references :rbac_permission, null: false, foreign_key: true
      
      # Optional constraints on permission
      t.json :constraints, default: {} # For future: scoped permissions, conditions, etc.
      
      # Timestamps
      t.timestamps
      
      # Indexes
      t.index [:rbac_role_id, :rbac_permission_id], unique: true, name: 'index_role_permissions_on_role_and_permission'
    end
  end
end

