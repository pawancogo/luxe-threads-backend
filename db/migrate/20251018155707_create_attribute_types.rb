class CreateAttributeTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :attribute_types do |t|
      t.string :name

      t.timestamps
    end

    # Add index for performance
    add_index :attribute_types, :name, unique: true
  end
end
