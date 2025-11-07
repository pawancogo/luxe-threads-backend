class CreateSupplierAccountUsers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:supplier_account_users)
      create_table :supplier_account_users do |t|
      t.references :supplier_profile, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      # Supplier Account Role
      t.string :role, null: false
      # Values: owner, admin, product_manager, order_manager, accountant, staff
      
      # Status
      t.string :status, null: false, default: 'active'
      # Values: active, inactive, suspended, pending_invitation
      
      # Invitation
      t.references :invited_by, foreign_key: { to_table: :users }
      t.timestamp :invited_at
      t.string :invitation_token, limit: 255
      t.timestamp :invitation_expires_at
      t.timestamp :accepted_at
      
      # Access Control (permissions)
      t.boolean :can_manage_products, default: false
      t.boolean :can_manage_orders, default: false
      t.boolean :can_view_financials, default: false
      t.boolean :can_manage_users, default: false
      t.boolean :can_manage_settings, default: false
      t.boolean :can_view_analytics, default: false
      
      # Custom Permissions (SQLite compatible: use text for JSON)
      t.text :custom_permissions, default: '{}'
      
      # Activity Tracking
      t.timestamp :last_active_at
      
      t.timestamps
      end
      
      # Add unique constraint
      add_index :supplier_account_users, [:supplier_profile_id, :user_id], unique: true, name: 'idx_supplier_account_users_unique'
      
      # Add indexes
      add_index :supplier_account_users, :role
      add_index :supplier_account_users, :status
      add_index :supplier_account_users, :invitation_token, unique: true
    else
      # Table exists, just add missing indexes
      add_index :supplier_account_users, [:supplier_profile_id, :user_id], unique: true, name: 'idx_supplier_account_users_unique' unless index_exists?(:supplier_account_users, [:supplier_profile_id, :user_id], name: 'idx_supplier_account_users_unique')
      add_index :supplier_account_users, :role unless index_exists?(:supplier_account_users, :role)
      add_index :supplier_account_users, :status unless index_exists?(:supplier_account_users, :status)
      add_index :supplier_account_users, :invitation_token, unique: true unless index_exists?(:supplier_account_users, :invitation_token)
    end
    
    # Note: SQLite doesn't support check constraints
    # These will be enforced at application level
  end
end

