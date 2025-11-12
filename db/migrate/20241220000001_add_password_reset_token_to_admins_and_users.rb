class AddPasswordResetTokenToAdminsAndUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :password_reset_token, :string
    add_column :admins, :password_reset_token_expires_at, :datetime
    add_index :admins, :password_reset_token
    
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_token_expires_at, :datetime
    add_index :users, :password_reset_token
  end
end

