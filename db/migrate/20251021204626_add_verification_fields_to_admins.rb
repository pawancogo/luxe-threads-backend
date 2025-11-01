class AddVerificationFieldsToAdmins < ActiveRecord::Migration[7.1]
  def change
    add_column :admins, :temp_password, :string
    add_column :admins, :temp_password_expires_at, :datetime
    add_column :admins, :password_reset_required, :boolean
  end
end
