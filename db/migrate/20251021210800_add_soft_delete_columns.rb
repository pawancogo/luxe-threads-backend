class AddSoftDeleteColumns < ActiveRecord::Migration[7.1]
  def change
    # Add deleted_at column to all main tables for soft deletes
    add_column :admins, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :suppliers, :deleted_at, :datetime
    add_column :products, :deleted_at, :datetime
    add_column :orders, :deleted_at, :datetime
    add_column :addresses, :deleted_at, :datetime
    add_column :reviews, :deleted_at, :datetime
    add_column :carts, :deleted_at, :datetime
    add_column :wishlists, :deleted_at, :datetime
    add_column :cart_items, :deleted_at, :datetime
    add_column :wishlist_items, :deleted_at, :datetime
    
    # Add indexes for soft delete queries
    add_index :admins, :deleted_at
    add_index :users, :deleted_at
    add_index :suppliers, :deleted_at
    add_index :products, :deleted_at
    add_index :orders, :deleted_at
    add_index :addresses, :deleted_at
    add_index :reviews, :deleted_at
    add_index :carts, :deleted_at
    add_index :wishlists, :deleted_at
    add_index :cart_items, :deleted_at
    add_index :wishlist_items, :deleted_at
  end
end


