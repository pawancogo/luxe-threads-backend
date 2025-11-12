class AddVerificationTokenToEmailVerifications < ActiveRecord::Migration[7.0]
  def change
    add_column :email_verifications, :verification_token, :string
    add_index :email_verifications, :verification_token
    # OTP column will be kept for backward compatibility but won't be used
  end
end

