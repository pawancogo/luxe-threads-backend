class AddEmailVerifiedToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :email_verified, :boolean
  end
end
