class CreateReturnItems < ActiveRecord::Migration[7.1]
  def change
    create_table :return_items do |t|
      t.references :return_request, null: false, foreign_key: true
      t.references :order_item, null: false, foreign_key: true
      t.integer :quantity
      t.text :reason

      t.timestamps
    end
  end
end
