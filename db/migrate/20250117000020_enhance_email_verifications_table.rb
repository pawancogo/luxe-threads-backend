# frozen_string_literal: true

class EnhanceEmailVerificationsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :email_verifications, :attempts, :integer, default: 0 unless column_exists?(:email_verifications, :attempts)
    add_column :email_verifications, :max_attempts, :integer, default: 3 unless column_exists?(:email_verifications, :max_attempts)
    
    # Note: verified and verified_at may already exist from previous migrations
    add_column :email_verifications, :verified, :boolean, default: false unless column_exists?(:email_verifications, :verified)
    add_column :email_verifications, :verified_at, :timestamp unless column_exists?(:email_verifications, :verified_at)
    
    # Add indexes
    add_index :email_verifications, :expires_at unless index_exists?(:email_verifications, :expires_at)
  end
end

