class CreateProductVariantAttributes < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variant_attributes do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :attribute_value, null: false, foreign_key: true

      t.timestamps
    end
  end
end
