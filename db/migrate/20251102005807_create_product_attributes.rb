# frozen_string_literal: true

class CreateProductAttributes < ActiveRecord::Migration[7.1]
  def change
    create_table :product_attributes do |t|
      t.references :product, null: false, foreign_key: true
      t.references :attribute_value, null: false, foreign_key: true

      t.timestamps
    end

    # Add unique index to prevent duplicate attributes for same product
    add_index :product_attributes, [:product_id, :attribute_value_id], unique: true
  end
end
