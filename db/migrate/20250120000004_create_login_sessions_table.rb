# frozen_string_literal: true

class CreateLoginSessionsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:login_sessions)
      create_table :login_sessions do |t|
        # User/Admin reference (polymorphic)
        t.references :user, polymorphic: true, null: false, index: true
        
        # Session Details
        t.string :session_token, limit: 255, null: false
        t.string :jwt_token_id, limit: 255 # For token revocation if needed
        
        # Location & Network
        t.string :ip_address, limit: 50
        t.string :country, limit: 100
        t.string :region, limit: 100
        t.string :city, limit: 100
        t.string :timezone, limit: 50
        
        # Device Information
        t.string :device_type, limit: 50 # desktop, mobile, tablet
        t.string :device_name, limit: 100 # iPhone 13, MacBook Pro
        t.string :os_name, limit: 50 # iOS, Android, Windows, macOS
        t.string :os_version, limit: 50 # 15.0, 14.0, 11.0
        t.string :browser_name, limit: 50 # Chrome, Safari, Firefox
        t.string :browser_version, limit: 50 # 120.0, 17.0
        t.text :user_agent, limit: 500
        
        # Screen/Display Info
        t.string :screen_resolution, limit: 50 # 1920x1080
        t.string :viewport_size, limit: 50 # 1440x900
        
        # Network Info
        t.string :connection_type, limit: 50 # wifi, cellular, ethernet
        t.boolean :is_mobile, default: false
        t.boolean :is_tablet, default: false
        t.boolean :is_desktop, default: false
        
        # Login Details
        t.string :login_method, limit: 50 # password, oauth, magic_link
        t.boolean :is_successful, default: true
        t.string :failure_reason, limit: 255
        
        # Session Status
        t.datetime :logged_in_at, null: false
        t.datetime :logged_out_at
        t.datetime :last_activity_at
        t.boolean :is_active, default: true
        t.boolean :is_expired, default: false
        
        # Additional Metadata
        t.text :metadata, default: '{}' # JSON for additional info
        
        t.timestamps
      end
      
      add_index :login_sessions, :session_token, unique: true unless index_exists?(:login_sessions, :session_token)
      add_index :login_sessions, :logged_in_at unless index_exists?(:login_sessions, :logged_in_at)
      add_index :login_sessions, [:user_type, :user_id, :is_active] unless index_exists?(:login_sessions, [:user_type, :user_id, :is_active])
      add_index :login_sessions, :ip_address unless index_exists?(:login_sessions, :ip_address)
    end
  end
end

