# frozen_string_literal: true

class EnhanceSupplierAccountUsersForRbac < ActiveRecord::Migration[7.1]
  def change
    # Add RBAC role assignment to supplier account users
    add_reference :supplier_account_users, :rbac_role, null: true, foreign_key: true unless column_exists?(:supplier_account_users, :rbac_role_id)
    add_column :supplier_account_users, :custom_permissions, :json, default: {} unless column_exists?(:supplier_account_users, :custom_permissions)
    add_column :supplier_account_users, :role_assigned_at, :datetime unless column_exists?(:supplier_account_users, :role_assigned_at)
    add_reference :supplier_account_users, :role_assigned_by, null: true, foreign_key: { to_table: :users } unless column_exists?(:supplier_account_users, :role_assigned_by_id)
    
    # Indexes
    add_index :supplier_account_users, :rbac_role_id unless index_exists?(:supplier_account_users, :rbac_role_id)
    add_index :supplier_account_users, [:supplier_profile_id, :rbac_role_id] unless index_exists?(:supplier_account_users, [:supplier_profile_id, :rbac_role_id])
  end
end

