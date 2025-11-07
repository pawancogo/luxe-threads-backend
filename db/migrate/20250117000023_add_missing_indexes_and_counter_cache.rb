# frozen_string_literal: true

class AddMissingIndexesAndCounterCache < ActiveRecord::Migration[7.1]
  def change
    # Add counter cache column for orders
    add_column :users, :orders_count, :integer, default: 0, null: false unless column_exists?(:users, :orders_count)
    
    # Add indexes for product_views
    add_index :product_views, [:product_id, :created_at], name: 'index_product_views_on_product_and_created_at' unless index_exists?(:product_views, [:product_id, :created_at])
    add_index :product_views, :user_id unless index_exists?(:product_views, :user_id)
    add_index :product_views, :session_id unless index_exists?(:product_views, :session_id)
    
    # Add indexes for user_searches
    add_index :user_searches, [:user_id, :searched_at], name: 'index_user_searches_on_user_and_searched_at' unless index_exists?(:user_searches, [:user_id, :searched_at])
    add_index :user_searches, :search_query unless index_exists?(:user_searches, :search_query)
    
    # Add indexes for notifications
    add_index :notifications, [:user_id, :is_read, :created_at], name: 'index_notifications_on_user_read_created' unless index_exists?(:notifications, [:user_id, :is_read, :created_at])
    add_index :notifications, :notification_type unless index_exists?(:notifications, :notification_type)
    
    # Add indexes for support_tickets
    add_index :support_tickets, [:user_id, :status], name: 'index_support_tickets_on_user_and_status' unless index_exists?(:support_tickets, [:user_id, :status])
    add_index :support_tickets, [:assigned_to_id, :status], name: 'index_support_tickets_on_assigned_and_status' unless index_exists?(:support_tickets, [:assigned_to_id, :status])
    add_index :support_tickets, :ticket_id, unique: true unless index_exists?(:support_tickets, :ticket_id, unique: true)
    
    # Add indexes for loyalty_points_transactions
    add_index :loyalty_points_transactions, [:user_id, :transaction_type, :created_at], name: 'index_loyalty_points_on_user_type_created' unless index_exists?(:loyalty_points_transactions, [:user_id, :transaction_type, :created_at])
    
    # Add indexes for support_ticket_messages
    add_index :support_ticket_messages, [:support_ticket_id, :created_at], name: 'index_support_messages_on_ticket_and_created' unless index_exists?(:support_ticket_messages, [:support_ticket_id, :created_at])
    
    # Add indexes for supplier_analytics
    add_index :supplier_analytics, [:supplier_profile_id, :date], unique: true, name: 'index_supplier_analytics_on_supplier_and_date' unless index_exists?(:supplier_analytics, [:supplier_profile_id, :date], unique: true)
    
    # Add indexes for referrals
    add_index :referrals, [:referrer_id, :status], name: 'index_referrals_on_referrer_and_status' unless index_exists?(:referrals, [:referrer_id, :status])
    add_index :referrals, [:referred_id, :status], name: 'index_referrals_on_referred_and_status' unless index_exists?(:referrals, [:referred_id, :status])
    
    # Update counter cache for existing users
    if User.any?
      User.find_each do |user|
        User.reset_counters(user.id, :orders)
      end
    end
  end
end

