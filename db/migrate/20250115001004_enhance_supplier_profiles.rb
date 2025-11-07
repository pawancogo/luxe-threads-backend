class EnhanceSupplierProfiles < ActiveRecord::Migration[7.1]
  def change
    # Add owner_user_id (nullable first, will be populated, then made NOT NULL)
    unless column_exists?(:supplier_profiles, :owner_id)
      add_reference :supplier_profiles, :owner, foreign_key: { to_table: :users }, null: true, index: true
    end
    
    # Add company information
    add_column :supplier_profiles, :company_registration_number, :string, limit: 100 unless column_exists?(:supplier_profiles, :company_registration_number)
    add_column :supplier_profiles, :pan_number, :string, limit: 20 unless column_exists?(:supplier_profiles, :pan_number)
    add_column :supplier_profiles, :cin_number, :string, limit: 50 unless column_exists?(:supplier_profiles, :cin_number)
    
    # Add business details
    add_column :supplier_profiles, :business_type, :string, limit: 50 unless column_exists?(:supplier_profiles, :business_type)
    add_column :supplier_profiles, :business_category, :string, limit: 100 unless column_exists?(:supplier_profiles, :business_category)
    
    # Add warehouse addresses (SQLite compatible: use text for JSON)
    add_column :supplier_profiles, :warehouse_addresses, :text, default: '[]' unless column_exists?(:supplier_profiles, :warehouse_addresses)
    
    # Add contact information
    add_column :supplier_profiles, :contact_email, :string unless column_exists?(:supplier_profiles, :contact_email)
    add_column :supplier_profiles, :contact_phone, :string, limit: 20 unless column_exists?(:supplier_profiles, :contact_phone)
    add_column :supplier_profiles, :support_email, :string unless column_exists?(:supplier_profiles, :support_email)
    add_column :supplier_profiles, :support_phone, :string, limit: 20 unless column_exists?(:supplier_profiles, :support_phone)
    
    # Add verification documents (SQLite compatible: use text for JSON)
    add_column :supplier_profiles, :verification_documents, :text, default: '[]' unless column_exists?(:supplier_profiles, :verification_documents)
    
    # Add supplier tier
    add_column :supplier_profiles, :supplier_tier, :string, limit: 50, default: 'basic' unless column_exists?(:supplier_profiles, :supplier_tier)
    add_column :supplier_profiles, :tier_upgraded_at, :timestamp unless column_exists?(:supplier_profiles, :tier_upgraded_at)
    
    # Add multi-user settings
    add_column :supplier_profiles, :max_users, :integer, default: 1 unless column_exists?(:supplier_profiles, :max_users)
    add_column :supplier_profiles, :allow_invites, :boolean, default: false unless column_exists?(:supplier_profiles, :allow_invites)
    add_column :supplier_profiles, :invite_code, :string, limit: 50 unless column_exists?(:supplier_profiles, :invite_code)
    
    # Add metrics
    add_column :supplier_profiles, :active_products_count, :integer, default: 0 unless column_exists?(:supplier_profiles, :active_products_count)
    add_column :supplier_profiles, :total_reviews_count, :integer, default: 0 unless column_exists?(:supplier_profiles, :total_reviews_count)
    
    # Add payment information
    add_column :supplier_profiles, :bank_branch, :string unless column_exists?(:supplier_profiles, :bank_branch)
    add_column :supplier_profiles, :account_holder_name, :string unless column_exists?(:supplier_profiles, :account_holder_name)
    add_column :supplier_profiles, :upi_id, :string unless column_exists?(:supplier_profiles, :upi_id)
    
    # Add operational settings
    add_column :supplier_profiles, :payment_cycle, :string, limit: 50, default: 'weekly' unless column_exists?(:supplier_profiles, :payment_cycle)
    add_column :supplier_profiles, :handling_time_days, :integer, default: 1 unless column_exists?(:supplier_profiles, :handling_time_days)
    add_column :supplier_profiles, :shipping_zones, :text, default: '{}' unless column_exists?(:supplier_profiles, :shipping_zones)
    add_column :supplier_profiles, :free_shipping_above, :decimal, precision: 10, scale: 2 unless column_exists?(:supplier_profiles, :free_shipping_above)
    
    # Add account status
    add_column :supplier_profiles, :is_active, :boolean, default: true unless column_exists?(:supplier_profiles, :is_active)
    add_column :supplier_profiles, :is_suspended, :boolean, default: false unless column_exists?(:supplier_profiles, :is_suspended)
    add_column :supplier_profiles, :suspended_reason, :text unless column_exists?(:supplier_profiles, :suspended_reason)
    add_column :supplier_profiles, :suspended_at, :timestamp unless column_exists?(:supplier_profiles, :suspended_at)
    
    # Add indexes
    add_index :supplier_profiles, :supplier_tier unless index_exists?(:supplier_profiles, :supplier_tier)
    add_index :supplier_profiles, :invite_code, unique: true unless index_exists?(:supplier_profiles, :invite_code)
    add_index :supplier_profiles, :is_active unless index_exists?(:supplier_profiles, :is_active)
    
    # Note: SQLite doesn't support GIN indexes for JSON or check constraints
    # These will be enforced at application level
    
    # Data migration: Set owner_id from user_id (for existing records)
    execute <<-SQL
      UPDATE supplier_profiles
      SET owner_id = user_id
      WHERE owner_id IS NULL AND user_id IS NOT NULL;
    SQL
    
    # Data migration: Set default supplier_tier
    execute <<-SQL
      UPDATE supplier_profiles
      SET supplier_tier = 'basic'
      WHERE supplier_tier IS NULL;
    SQL
    
    # Data migration: Initialize metrics
    execute <<-SQL
      UPDATE supplier_profiles
      SET active_products_count = COALESCE(active_products_count, 0),
          total_reviews_count = COALESCE(total_reviews_count, 0)
      WHERE active_products_count IS NULL OR total_reviews_count IS NULL;
    SQL
  end
end

