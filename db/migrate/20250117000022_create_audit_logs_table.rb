# frozen_string_literal: true

class CreateAuditLogsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:audit_logs)
      create_table :audit_logs do |t|
        # Entity
        t.string :auditable_type, limit: 50, null: false
        t.integer :auditable_id, null: false
        
        # Action
        t.string :action, limit: 50, null: false # create, update, delete
        t.text :changes, default: '{}' # Before/after changes (JSON)
        
        # User
        t.references :user, foreign_key: true
        t.string :user_type, limit: 50 # user, admin, supplier
        t.string :ip_address, limit: 50
        t.text :user_agent
        
        t.timestamps
      end
      
      add_index :audit_logs, [:auditable_type, :auditable_id] unless index_exists?(:audit_logs, [:auditable_type, :auditable_id])
      add_index :audit_logs, :action unless index_exists?(:audit_logs, :action)
      add_index :audit_logs, :created_at unless index_exists?(:audit_logs, :created_at)
    end
  end
end

