# frozen_string_literal: true

class CreateSupportTicketMessagesTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:support_ticket_messages)
      create_table :support_ticket_messages do |t|
        t.references :support_ticket, null: false, foreign_key: true
        
        # Message
        t.text :message, null: false
        t.string :sender_type, limit: 50, null: false # user, admin
        t.integer :sender_id, null: false # User ID or Admin ID
        
        # Attachments
        t.text :attachments, default: '[]' # Array of file URLs (JSON)
        
        # Status
        t.boolean :is_internal, default: false # Internal notes not visible to user
        t.boolean :is_read, default: false
        t.timestamp :read_at
        
        t.timestamps
      end
      
      add_index :support_ticket_messages, [:sender_type, :sender_id] unless index_exists?(:support_ticket_messages, [:sender_type, :sender_id])
      add_index :support_ticket_messages, :created_at unless index_exists?(:support_ticket_messages, :created_at)
    end
  end
end

