class AddVerificationFieldsToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :temp_password_digest, :string
    add_column :suppliers, :temp_password_expires_at, :datetime
    add_column :suppliers, :password_reset_required, :boolean, default: false
  end
end
