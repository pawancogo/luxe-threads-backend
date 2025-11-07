# frozen_string_literal: true

class EnhanceCartItemsTable < ActiveRecord::Migration[7.1]
  def change
    # Add price_when_added column if it doesn't exist
    add_column :cart_items, :price_when_added, :decimal, precision: 10, scale: 2 unless column_exists?(:cart_items, :price_when_added)
  end
end

