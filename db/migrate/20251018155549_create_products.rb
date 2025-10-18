class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :supplier_profile, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :brand, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :status
      t.references :verified_by_admin, null: true, foreign_key: { to_table: :users }
      t.datetime :verified_at

      t.timestamps
    end
  end
end
