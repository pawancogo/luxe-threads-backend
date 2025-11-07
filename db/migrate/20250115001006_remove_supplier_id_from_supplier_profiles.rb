class RemoveSupplierIdFromSupplierProfiles < ActiveRecord::Migration[7.1]
  def up
    # Check if supplier_id column exists
    return unless column_exists?(:supplier_profiles, :supplier_id)
    
    # First, ensure all supplier_profiles have owner_id set from suppliers
    # This is already done by the rake task, but we'll try to set it here too if needed
    # Only if suppliers table still exists
    if table_exists?(:suppliers)
      execute <<-SQL
        UPDATE supplier_profiles
        SET owner_id = (
          SELECT users.id 
          FROM users 
          JOIN suppliers ON users.email = suppliers.email 
          WHERE supplier_profiles.supplier_id = suppliers.id
        )
        WHERE supplier_id IS NOT NULL AND owner_id IS NULL;
      SQL
    end
    
    # Remove foreign key constraint if it exists
    if foreign_key_exists?(:supplier_profiles, :suppliers)
      remove_foreign_key :supplier_profiles, :suppliers
    end
    
    # Remove index if it exists
    if index_exists?(:supplier_profiles, :supplier_id)
      remove_index :supplier_profiles, :supplier_id
    end
    
    # Remove column
    remove_column :supplier_profiles, :supplier_id, :integer
    
    Rails.logger.info "✅ Removed supplier_id from supplier_profiles"
  end

  def down
    # Add back supplier_id column
    add_reference :supplier_profiles, :supplier, foreign_key: true, index: true
    
    Rails.logger.warn "⚠️  supplier_id restoration may not be complete. Check backup tables."
  end
end

