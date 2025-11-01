class AddVerificationFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :temp_password_digest, :string
    add_column :users, :temp_password_expires_at, :datetime
    add_column :users, :password_reset_required, :boolean, default: false
  end
end
