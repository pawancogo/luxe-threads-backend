class AddPolymorphicColumnsToEmailVerifications < ActiveRecord::Migration[7.1]
  def change
    add_reference :email_verifications, :verifiable, polymorphic: true, null: true
    add_index :email_verifications, [:verifiable_type, :verifiable_id]
  end
end


