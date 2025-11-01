class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :password_digest
      t.string :role

      t.timestamps
    end
    add_index :admins, :email, unique: true
    add_index :admins, :phone_number, unique: true
  end
end
