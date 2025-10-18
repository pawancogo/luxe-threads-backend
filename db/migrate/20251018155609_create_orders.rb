class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shipping_address, null: false, foreign_key: true
      t.references :billing_address, null: false, foreign_key: true
      t.string :status
      t.string :payment_status
      t.string :shipping_method
      t.decimal :total_amount

      t.timestamps
    end
  end
end
