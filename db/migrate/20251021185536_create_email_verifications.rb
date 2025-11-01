class CreateEmailVerifications < ActiveRecord::Migration[7.1]
  def change
    create_table :email_verifications do |t|
      t.string :email
      t.string :otp
      t.datetime :expires_at
      t.integer :attempts
      t.integer :max_attempts
      t.boolean :verified

      t.timestamps
    end
    add_index :email_verifications, :email, unique: true
  end
end
