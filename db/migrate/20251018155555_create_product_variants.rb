class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku
      t.decimal :price
      t.decimal :discounted_price
      t.integer :stock_quantity
      t.float :weight_kg

      t.timestamps
    end
    add_index :product_variants, :sku, unique: true
  end
end
