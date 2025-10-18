class CreateReturnRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :return_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.string :status
      t.string :resolution_type

      t.timestamps
    end
  end
end
