class AddInvitationFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :invitation_token, :string
    add_column :users, :invitation_sent_at, :datetime
    add_column :users, :invitation_expires_at, :datetime
    add_column :users, :invited_by_id, :integer
    add_column :users, :invitation_accepted_at, :datetime
    add_column :users, :invitation_role, :string
    add_column :users, :invitation_status, :string, default: nil
    
    add_index :users, :invitation_token, unique: true
    add_index :users, :invited_by_id
    add_index :users, :invitation_status
    
    add_foreign_key :users, :users, column: :invited_by_id
  end
end
