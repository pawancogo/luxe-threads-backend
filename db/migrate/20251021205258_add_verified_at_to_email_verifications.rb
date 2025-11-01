class AddVerifiedAtToEmailVerifications < ActiveRecord::Migration[7.1]
  def change
    add_column :email_verifications, :verified_at, :datetime
  end
end
