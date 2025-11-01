class AddEmailVerifiedToAdmins < ActiveRecord::Migration[7.1]
  def change
    add_column :admins, :email_verified, :boolean
  end
end
