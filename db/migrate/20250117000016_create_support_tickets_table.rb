# frozen_string_literal: true

class CreateSupportTicketsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:support_tickets)
      create_table :support_tickets do |t|
        t.string :ticket_id, limit: 50, null: false
        t.references :user, null: false, foreign_key: true
        
        # Ticket Details
        t.string :subject, limit: 255, null: false
        t.text :description, null: false
        t.string :category, limit: 50, null: false
        # Values: order_issue, product_issue, payment_issue, account_issue, other
        
        # Status
        t.string :status, limit: 50, null: false, default: 'open'
        # Values: open, in_progress, waiting_customer, resolved, closed
        t.string :priority, limit: 50, default: 'medium'
        # Values: low, medium, high, urgent
        
        # Assignment
        t.references :assigned_to, foreign_key: { to_table: :admins }
        t.timestamp :assigned_at
        
        # Resolution
        t.text :resolution
        t.references :resolved_by, foreign_key: { to_table: :admins }
        t.timestamp :resolved_at
        
        # Related Resources
        t.references :order, foreign_key: true
        t.references :product, foreign_key: true
        
        t.timestamps
        t.timestamp :closed_at
      end
      
      add_index :support_tickets, :ticket_id, unique: true unless index_exists?(:support_tickets, :ticket_id)
      add_index :support_tickets, :status unless index_exists?(:support_tickets, :status)
      add_index :support_tickets, :assigned_to_id unless index_exists?(:support_tickets, :assigned_to_id)
      add_index :support_tickets, :created_at unless index_exists?(:support_tickets, :created_at)
    end
  end
end

