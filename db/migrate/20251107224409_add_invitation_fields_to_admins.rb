class AddInvitationFieldsToAdmins < ActiveRecord::Migration[7.1]
  def change
    add_column :admins, :invitation_token, :string
    add_column :admins, :invitation_sent_at, :datetime
    add_column :admins, :invitation_expires_at, :datetime
    add_column :admins, :invited_by_id, :integer
    add_column :admins, :invitation_accepted_at, :datetime
    add_column :admins, :invitation_status, :string, default: nil
    
    add_index :admins, :invitation_token, unique: true
    add_index :admins, :invited_by_id
    add_index :admins, :invitation_status
    
    add_foreign_key :admins, :admins, column: :invited_by_id
  end
end
