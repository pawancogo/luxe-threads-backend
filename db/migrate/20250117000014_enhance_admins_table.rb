# frozen_string_literal: true

class EnhanceAdminsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :admins, :is_active, :boolean, default: true unless column_exists?(:admins, :is_active)
    add_column :admins, :is_blocked, :boolean, default: false unless column_exists?(:admins, :is_blocked)
    add_column :admins, :last_login_at, :timestamp unless column_exists?(:admins, :last_login_at)
    add_column :admins, :password_changed_at, :timestamp unless column_exists?(:admins, :password_changed_at)
    add_column :admins, :permissions, :text, default: '{}' unless column_exists?(:admins, :permissions) # JSON
    
    # Add indexes
    add_index :admins, :is_active unless index_exists?(:admins, :is_active)
  end
end

