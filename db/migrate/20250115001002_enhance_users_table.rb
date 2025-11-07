class EnhanceUsersTable < ActiveRecord::Migration[7.1]
  def change
    # Add profile information (only if column doesn't exist)
    add_column :users, :alternate_phone, :string unless column_exists?(:users, :alternate_phone)
    add_column :users, :date_of_birth, :date unless column_exists?(:users, :date_of_birth)
    add_column :users, :gender, :string unless column_exists?(:users, :gender)
    add_column :users, :profile_image_url, :string, limit: 500 unless column_exists?(:users, :profile_image_url)
    
    # Add referral & loyalty

    add_column :users, :referral_code, :string, limit: 50 unless column_exists?(:users, :referral_code)
    unless column_exists?(:users, :referred_by_id)
      add_reference :users, :referred_by, foreign_key: { to_table: :users }, index: true
    end
    add_column :users, :loyalty_points, :integer, default: 0 unless column_exists?(:users, :loyalty_points)
    add_column :users, :total_loyalty_points_earned, :integer, default: 0 unless column_exists?(:users, :total_loyalty_points_earned)
    
    # Add preferences
    add_column :users, :preferred_language, :string, limit: 10, default: 'en' unless column_exists?(:users, :preferred_language)
    add_column :users, :preferred_currency, :string, limit: 10, default: 'INR' unless column_exists?(:users, :preferred_currency)
    add_column :users, :timezone, :string, limit: 50, default: 'Asia/Kolkata' unless column_exists?(:users, :timezone)
    # SQLite compatible: use text for JSON data
    add_column :users, :notification_preferences, :text, default: '{"email":true,"sms":true,"push":true}' unless column_exists?(:users, :notification_preferences)
    
    # Add account status
    add_column :users, :is_active, :boolean, default: true unless column_exists?(:users, :is_active)
    add_column :users, :is_blocked, :boolean, default: false unless column_exists?(:users, :is_blocked)
    add_column :users, :blocked_reason, :text unless column_exists?(:users, :blocked_reason)
    add_column :users, :blocked_at, :timestamp unless column_exists?(:users, :blocked_at)
    
    # Add activity tracking
    add_column :users, :last_login_at, :timestamp unless column_exists?(:users, :last_login_at)
    add_column :users, :last_active_at, :timestamp unless column_exists?(:users, :last_active_at)
    
    # Add social login
    add_column :users, :google_id, :string unless column_exists?(:users, :google_id)
    add_column :users, :facebook_id, :string unless column_exists?(:users, :facebook_id)
    add_column :users, :apple_id, :string unless column_exists?(:users, :apple_id)
    
    # Add password tracking
    add_column :users, :password_changed_at, :timestamp unless column_exists?(:users, :password_changed_at)
    
    # Add indexes
    add_index :users, :referral_code, unique: true unless index_exists?(:users, :referral_code)
    add_index :users, :is_active unless index_exists?(:users, :is_active)
    add_index :users, :last_active_at unless index_exists?(:users, :last_active_at)
    
    # Note: SQLite doesn't support check constraints or GIN indexes
    # These will be enforced at application level
    # For PostgreSQL, add constraints and GIN indexes in a separate migration
  end
end

