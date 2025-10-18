class CreateProductImages < ActiveRecord::Migration[7.1]
  def change
    create_table :product_images do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.string :image_url
      t.string :alt_text
      t.integer :display_order

      t.timestamps
    end
  end
end
