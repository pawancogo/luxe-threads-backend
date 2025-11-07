class DropSuppliersTable < ActiveRecord::Migration[7.1]
  def up
    # Only drop if table exists
    return unless table_exists?(:suppliers)
    
    # Verify that all suppliers have been migrated
    supplier_count = execute("SELECT COUNT(*) FROM suppliers").first['count'].to_i
    user_supplier_count = execute("SELECT COUNT(*) FROM users WHERE role = 'supplier'").first['count'].to_i
    
    Rails.logger.info "Suppliers to migrate: #{supplier_count}"
    Rails.logger.info "Users with supplier role: #{user_supplier_count}"
    
    if supplier_count > 0 && user_supplier_count == 0
      raise "❌ Cannot drop suppliers table: No users with supplier role found. Run supplier migration first."
    end
    
    # Drop the suppliers table
    drop_table :suppliers
    
    Rails.logger.info "✅ Suppliers table dropped successfully"
  end

  def down
    # Recreate suppliers table structure (for rollback)
    create_table :suppliers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :password_digest
      t.string :role
      t.boolean :email_verified
      t.string :temp_password_digest
      t.timestamp :temp_password_expires_at
      t.boolean :password_reset_required, default: false
      t.timestamp :deleted_at
      
      t.timestamps
    end
    
    add_index :suppliers, :email, unique: true
    add_index :suppliers, :phone_number, unique: true
    add_index :suppliers, :deleted_at
    
    Rails.logger.warn "⚠️  Suppliers table recreated but data must be restored from backup"
  end
end

