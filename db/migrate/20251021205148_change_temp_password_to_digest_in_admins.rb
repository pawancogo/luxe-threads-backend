class ChangeTempPasswordToDigestInAdmins < ActiveRecord::Migration[7.1]
  def change
    # Remove the old temp_password column and add temp_password_digest
    remove_column :admins, :temp_password, :string
    add_column :admins, :temp_password_digest, :string
  end
end
