# frozen_string_literal: true

class EnhanceWishlistItemsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :wishlist_items, :notes, :text unless column_exists?(:wishlist_items, :notes)
    add_column :wishlist_items, :priority, :integer, default: 0 unless column_exists?(:wishlist_items, :priority)
    add_column :wishlist_items, :price_when_added, :decimal, precision: 10, scale: 2 unless column_exists?(:wishlist_items, :price_when_added)
    add_column :wishlist_items, :current_price, :decimal, precision: 10, scale: 2 unless column_exists?(:wishlist_items, :current_price)
    add_column :wishlist_items, :price_drop_notified, :boolean, default: false unless column_exists?(:wishlist_items, :price_drop_notified)
  end
end

