class CreateAttributeValues < ActiveRecord::Migration[7.1]
  def change
    create_table :attribute_values do |t|
      t.references :attribute_type, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end

    # Add unique index to prevent duplicate values for same attribute type
    add_index :attribute_values, [:attribute_type_id, :value], unique: true
  end
end
