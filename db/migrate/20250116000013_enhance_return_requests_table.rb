# frozen_string_literal: true

class EnhanceReturnRequestsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :return_requests, :return_id, :string, limit: 100 unless column_exists?(:return_requests, :return_id)
    add_column :return_requests, :order_item_id, :integer unless column_exists?(:return_requests, :order_item_id)
    add_column :return_requests, :status_updated_at, :timestamp unless column_exists?(:return_requests, :status_updated_at)
    add_column :return_requests, :status_history, :text unless column_exists?(:return_requests, :status_history) # JSONB -> TEXT for SQLite
    add_column :return_requests, :resolution_amount, :decimal, precision: 10, scale: 2 unless column_exists?(:return_requests, :resolution_amount)
    add_column :return_requests, :resolved_by_admin_id, :integer unless column_exists?(:return_requests, :resolved_by_admin_id)
    add_column :return_requests, :resolved_at, :timestamp unless column_exists?(:return_requests, :resolved_at)
    add_column :return_requests, :refund_id, :string, limit: 255 unless column_exists?(:return_requests, :refund_id)
    add_column :return_requests, :refund_status, :string, limit: 50 unless column_exists?(:return_requests, :refund_status)
    add_column :return_requests, :refund_amount, :decimal, precision: 10, scale: 2 unless column_exists?(:return_requests, :refund_amount)
    add_column :return_requests, :refund_transaction_id, :string, limit: 255 unless column_exists?(:return_requests, :refund_transaction_id)
    add_column :return_requests, :pickup_address_id, :integer unless column_exists?(:return_requests, :pickup_address_id)
    add_column :return_requests, :pickup_scheduled_at, :timestamp unless column_exists?(:return_requests, :pickup_scheduled_at)
    add_column :return_requests, :pickup_completed_at, :timestamp unless column_exists?(:return_requests, :pickup_completed_at)
    add_column :return_requests, :return_quantity, :integer unless column_exists?(:return_requests, :return_quantity)
    add_column :return_requests, :return_condition, :string, limit: 50 unless column_exists?(:return_requests, :return_condition)
    add_column :return_requests, :return_images, :text unless column_exists?(:return_requests, :return_images) # JSONB -> TEXT for SQLite
    
    # Add indexes
    add_index :return_requests, :return_id, unique: true unless index_exists?(:return_requests, :return_id)
    add_index :return_requests, :order_item_id unless index_exists?(:return_requests, :order_item_id)
    add_index :return_requests, :refund_status unless index_exists?(:return_requests, :refund_status)
    add_index :return_requests, :resolved_by_admin_id unless index_exists?(:return_requests, :resolved_by_admin_id)
  end
end


