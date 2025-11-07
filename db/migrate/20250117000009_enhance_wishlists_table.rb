# frozen_string_literal: true

class EnhanceWishlistsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :wishlists, :name, :string, limit: 255 unless column_exists?(:wishlists, :name)
    add_column :wishlists, :description, :text unless column_exists?(:wishlists, :description)
    add_column :wishlists, :is_public, :boolean, default: false unless column_exists?(:wishlists, :is_public)
    add_column :wishlists, :is_default, :boolean, default: false unless column_exists?(:wishlists, :is_default)
    add_column :wishlists, :share_token, :string, limit: 255 unless column_exists?(:wishlists, :share_token)
    add_column :wishlists, :share_enabled, :boolean, default: false unless column_exists?(:wishlists, :share_enabled)
    
    # Add indexes
    add_index :wishlists, :share_token, unique: true unless index_exists?(:wishlists, :share_token)
  end
end

