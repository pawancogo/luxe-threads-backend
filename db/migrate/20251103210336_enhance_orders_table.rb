# Phase 2: Enhance Orders Table
# Adds order tracking, payment details, shipping info, and status history
class EnhanceOrdersTable < ActiveRecord::Migration[7.1]
  def up
    # Order number (unique identifier)
    unless column_exists?(:orders, :order_number)
      add_column :orders, :order_number, :string
      add_index :orders, :order_number, unique: true unless index_exists?(:orders, :order_number)
    end

    # Status tracking
    unless column_exists?(:orders, :status_updated_at)
      add_column :orders, :status_updated_at, :datetime
      add_index :orders, :status_updated_at unless index_exists?(:orders, :status_updated_at)
    end

    # Status history (stored as TEXT for SQLite, JSON array string)
    unless column_exists?(:orders, :status_history)
      add_column :orders, :status_history, :text, default: '[]'
    end

    # Payment details
    unless column_exists?(:orders, :payment_method)
      add_column :orders, :payment_method, :string
      add_index :orders, :payment_method unless index_exists?(:orders, :payment_method)
    end

    unless column_exists?(:orders, :payment_id)
      add_column :orders, :payment_id, :string
      add_index :orders, :payment_id unless index_exists?(:orders, :payment_id)
    end

    unless column_exists?(:orders, :payment_gateway)
      add_column :orders, :payment_gateway, :string
    end

    unless column_exists?(:orders, :paid_at)
      add_column :orders, :paid_at, :datetime
      add_index :orders, :paid_at unless index_exists?(:orders, :paid_at)
    end

    # Pricing breakdown
    unless column_exists?(:orders, :tax_amount)
      add_column :orders, :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end

    unless column_exists?(:orders, :coupon_discount)
      add_column :orders, :coupon_discount, :decimal, precision: 10, scale: 2, default: 0.0
    end

    unless column_exists?(:orders, :loyalty_points_used)
      add_column :orders, :loyalty_points_used, :integer, default: 0
    end

    unless column_exists?(:orders, :loyalty_points_discount)
      add_column :orders, :loyalty_points_discount, :decimal, precision: 10, scale: 2, default: 0.0
    end

    unless column_exists?(:orders, :currency)
      add_column :orders, :currency, :string, default: 'INR'
    end

    # Shipping details
    unless column_exists?(:orders, :shipping_provider)
      add_column :orders, :shipping_provider, :string
    end

    unless column_exists?(:orders, :tracking_url)
      add_column :orders, :tracking_url, :string
    end

    # Delivery dates
    unless column_exists?(:orders, :estimated_delivery_date)
      add_column :orders, :estimated_delivery_date, :date
      add_index :orders, :estimated_delivery_date unless index_exists?(:orders, :estimated_delivery_date)
    end

    unless column_exists?(:orders, :actual_delivery_date)
      add_column :orders, :actual_delivery_date, :date
    end

    # Delivery slots
    unless column_exists?(:orders, :delivery_slot_start)
      add_column :orders, :delivery_slot_start, :datetime
    end

    unless column_exists?(:orders, :delivery_slot_end)
      add_column :orders, :delivery_slot_end, :datetime
    end

    # Notes
    unless column_exists?(:orders, :customer_notes)
      add_column :orders, :customer_notes, :text
    end

    unless column_exists?(:orders, :internal_notes)
      add_column :orders, :internal_notes, :text
    end

    # Data migration: Generate order_number for existing orders
    execute <<-SQL
      UPDATE orders
      SET order_number = 'ORD-' || strftime('%Y%m%d', created_at) || '-' || printf('%08d', id)
      WHERE order_number IS NULL OR order_number = '';
    SQL

    # Initialize status_updated_at
    execute <<-SQL
      UPDATE orders
      SET status_updated_at = updated_at
      WHERE status_updated_at IS NULL;
    SQL

    # Initialize status_history
    execute <<-SQL
      UPDATE orders
      SET status_history = json_array(
        json_object(
          'status', status,
          'timestamp', datetime(created_at),
          'note', 'Initial status'
        )
      )
      WHERE status_history IS NULL OR status_history = '';
    SQL
  end

  def down
    remove_column :orders, :order_number if column_exists?(:orders, :order_number)
    remove_column :orders, :status_updated_at if column_exists?(:orders, :status_updated_at)
    remove_column :orders, :status_history if column_exists?(:orders, :status_history)
    remove_column :orders, :payment_method if column_exists?(:orders, :payment_method)
    remove_column :orders, :payment_id if column_exists?(:orders, :payment_id)
    remove_column :orders, :payment_gateway if column_exists?(:orders, :payment_gateway)
    remove_column :orders, :paid_at if column_exists?(:orders, :paid_at)
    remove_column :orders, :tax_amount if column_exists?(:orders, :tax_amount)
    remove_column :orders, :coupon_discount if column_exists?(:orders, :coupon_discount)
    remove_column :orders, :loyalty_points_used if column_exists?(:orders, :loyalty_points_used)
    remove_column :orders, :loyalty_points_discount if column_exists?(:orders, :loyalty_points_discount)
    remove_column :orders, :currency if column_exists?(:orders, :currency)
    remove_column :orders, :shipping_provider if column_exists?(:orders, :shipping_provider)
    remove_column :orders, :tracking_url if column_exists?(:orders, :tracking_url)
    remove_column :orders, :estimated_delivery_date if column_exists?(:orders, :estimated_delivery_date)
    remove_column :orders, :actual_delivery_date if column_exists?(:orders, :actual_delivery_date)
    remove_column :orders, :delivery_slot_start if column_exists?(:orders, :delivery_slot_start)
    remove_column :orders, :delivery_slot_end if column_exists?(:orders, :delivery_slot_end)
    remove_column :orders, :customer_notes if column_exists?(:orders, :customer_notes)
    remove_column :orders, :internal_notes if column_exists?(:orders, :internal_notes)
  end
end
