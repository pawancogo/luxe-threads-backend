# frozen_string_literal: true

class CreateNotificationsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:notifications)
      create_table :notifications do |t|
        t.references :user, null: false, foreign_key: true
        
        # Notification Details
        t.string :title, limit: 255, null: false
        t.text :message, null: false
        t.string :notification_type, limit: 50, null: false
        # Values: order_update, payment, promotion, review, system, shipping
        
        # Data
        t.text :data, default: '{}' # Additional data (JSON)
        
        # Status
        t.boolean :is_read, default: false
        t.timestamp :read_at
        
        # Delivery
        t.boolean :sent_email, default: false
        t.boolean :sent_sms, default: false
        t.boolean :sent_push, default: false
        
        t.timestamps
      end
      
      add_index :notifications, :is_read unless index_exists?(:notifications, :is_read)
      add_index :notifications, :notification_type unless index_exists?(:notifications, :notification_type)
      add_index :notifications, :created_at unless index_exists?(:notifications, :created_at)
    end
  end
end

