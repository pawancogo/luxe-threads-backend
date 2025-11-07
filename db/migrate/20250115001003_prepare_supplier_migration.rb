class PrepareSupplierMigration < ActiveRecord::Migration[7.1]
  def up
    # Add migration tracking column to supplier_profiles
    unless column_exists?(:supplier_profiles, :migration_status)
      add_column :supplier_profiles, :migration_status, :string, default: 'pending'
    end
    unless index_exists?(:supplier_profiles, :migration_status)
      add_index :supplier_profiles, :migration_status
    end
    
    Rails.logger.info "✅ Migration tracking prepared"
  end

  def down
    remove_index :supplier_profiles, :migration_status if index_exists?(:supplier_profiles, :migration_status)
    remove_column :supplier_profiles, :migration_status if column_exists?(:supplier_profiles, :migration_status)
  end
end

