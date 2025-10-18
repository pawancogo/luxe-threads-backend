class CreateAttributeValues < ActiveRecord::Migration[7.1]
  def change
    create_table :attribute_values do |t|
      t.references :attribute_type, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
