# Phase 2: Enhance Order Items Table
# Adds supplier tracking, fulfillment status, pricing snapshots, and return management
class EnhanceOrderItemsTable < ActiveRecord::Migration[7.1]
  def up
    # Supplier tracking (required for Phase 1)
    unless column_exists?(:order_items, :supplier_profile_id)
      add_reference :order_items, :supplier_profile, foreign_key: true, null: false
      add_index :order_items, :supplier_profile_id unless index_exists?(:order_items, :supplier_profile_id)
    end

    # Product snapshot fields
    unless column_exists?(:order_items, :product_name)
      add_column :order_items, :product_name, :string
    end

    # Product variant attributes snapshot (stored as TEXT for SQLite, JSON string)
    unless column_exists?(:order_items, :product_variant_attributes)
      add_column :order_items, :product_variant_attributes, :text, default: '{}'
    end

    unless column_exists?(:order_items, :product_image_url)
      add_column :order_items, :product_image_url, :string
    end

    # Pricing snapshot
    unless column_exists?(:order_items, :discounted_price)
      add_column :order_items, :discounted_price, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:order_items, :final_price)
      add_column :order_items, :final_price, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:order_items, :currency)
      add_column :order_items, :currency, :string, default: 'INR'
    end

    # Fulfillment tracking
    unless column_exists?(:order_items, :fulfillment_status)
      add_column :order_items, :fulfillment_status, :string, default: 'pending'
      add_index :order_items, :fulfillment_status unless index_exists?(:order_items, :fulfillment_status)
    end

    unless column_exists?(:order_items, :shipped_at)
      add_column :order_items, :shipped_at, :datetime
      add_index :order_items, :shipped_at unless index_exists?(:order_items, :shipped_at)
    end

    unless column_exists?(:order_items, :delivered_at)
      add_column :order_items, :delivered_at, :datetime
    end

    # Tracking information
    unless column_exists?(:order_items, :tracking_number)
      add_column :order_items, :tracking_number, :string
      add_index :order_items, :tracking_number unless index_exists?(:order_items, :tracking_number)
    end

    unless column_exists?(:order_items, :tracking_url)
      add_column :order_items, :tracking_url, :string
    end

    # Supplier payment tracking
    unless column_exists?(:order_items, :supplier_commission)
      add_column :order_items, :supplier_commission, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:order_items, :supplier_paid)
      add_column :order_items, :supplier_paid, :boolean, default: false
      add_index :order_items, :supplier_paid unless index_exists?(:order_items, :supplier_paid)
    end

    unless column_exists?(:order_items, :supplier_paid_at)
      add_column :order_items, :supplier_paid_at, :datetime
    end

    unless column_exists?(:order_items, :supplier_payment_id)
      add_column :order_items, :supplier_payment_id, :string
    end

    # Return management
    unless column_exists?(:order_items, :is_returnable)
      add_column :order_items, :is_returnable, :boolean, default: true
    end

    unless column_exists?(:order_items, :return_deadline)
      add_column :order_items, :return_deadline, :date
      add_index :order_items, :return_deadline unless index_exists?(:order_items, :return_deadline)
    end

    unless column_exists?(:order_items, :return_requested)
      add_column :order_items, :return_requested, :boolean, default: false
    end

    # Data migration: Set supplier_profile_id from product's supplier
    # First, set to NULL temporarily to allow update
    execute <<-SQL
      UPDATE order_items
      SET supplier_profile_id = (
        SELECT supplier_profile_id 
        FROM products 
        WHERE products.id = (
          SELECT product_id 
          FROM product_variants 
          WHERE product_variants.id = order_items.product_variant_id
        )
      );
    SQL
    
    # Ensure all order_items have supplier_profile_id (set to 1 if missing as fallback)
    execute <<-SQL
      UPDATE order_items
      SET supplier_profile_id = (
        SELECT MIN(id) FROM supplier_profiles LIMIT 1
      )
      WHERE supplier_profile_id IS NULL;
    SQL

    # Data migration: Snapshot product details
    execute <<-SQL
      UPDATE order_items
      SET product_name = (
        SELECT products.name 
        FROM products 
        WHERE products.id = (
          SELECT product_id 
          FROM product_variants 
          WHERE product_variants.id = order_items.product_variant_id
        )
      ),
      product_image_url = (
        SELECT image_url 
        FROM product_images 
        WHERE product_images.product_variant_id = order_items.product_variant_id 
        ORDER BY product_images.display_order ASC 
        LIMIT 1
      ),
      discounted_price = (
        SELECT discounted_price 
        FROM product_variants 
        WHERE product_variants.id = order_items.product_variant_id
      ),
      final_price = COALESCE(price_at_purchase, 0),
      fulfillment_status = 'pending'
      WHERE product_name IS NULL;
    SQL

    # Set fulfillment_status based on order status
    execute <<-SQL
      UPDATE order_items
      SET fulfillment_status = CASE 
        WHEN (SELECT status FROM orders WHERE orders.id = order_items.order_id) = 'shipped' THEN 'shipped'
        WHEN (SELECT status FROM orders WHERE orders.id = order_items.order_id) = 'delivered' THEN 'delivered'
        ELSE 'pending'
      END
      WHERE fulfillment_status = 'pending';
    SQL

    # Set return_deadline (30 days from order date)
    execute <<-SQL
      UPDATE order_items
      SET return_deadline = date(
        (SELECT created_at FROM orders WHERE orders.id = order_items.order_id),
        '+30 days'
      )
      WHERE return_deadline IS NULL;
    SQL
  end

  def down
    remove_column :order_items, :supplier_profile_id if column_exists?(:order_items, :supplier_profile_id)
    remove_column :order_items, :product_name if column_exists?(:order_items, :product_name)
    remove_column :order_items, :product_variant_attributes if column_exists?(:order_items, :product_variant_attributes)
    remove_column :order_items, :product_image_url if column_exists?(:order_items, :product_image_url)
    remove_column :order_items, :discounted_price if column_exists?(:order_items, :discounted_price)
    remove_column :order_items, :final_price if column_exists?(:order_items, :final_price)
    remove_column :order_items, :currency if column_exists?(:order_items, :currency)
    remove_column :order_items, :fulfillment_status if column_exists?(:order_items, :fulfillment_status)
    remove_column :order_items, :shipped_at if column_exists?(:order_items, :shipped_at)
    remove_column :order_items, :delivered_at if column_exists?(:order_items, :delivered_at)
    remove_column :order_items, :tracking_number if column_exists?(:order_items, :tracking_number)
    remove_column :order_items, :tracking_url if column_exists?(:order_items, :tracking_url)
    remove_column :order_items, :supplier_commission if column_exists?(:order_items, :supplier_commission)
    remove_column :order_items, :supplier_paid if column_exists?(:order_items, :supplier_paid)
    remove_column :order_items, :supplier_paid_at if column_exists?(:order_items, :supplier_paid_at)
    remove_column :order_items, :supplier_payment_id if column_exists?(:order_items, :supplier_payment_id)
    remove_column :order_items, :is_returnable if column_exists?(:order_items, :is_returnable)
    remove_column :order_items, :return_deadline if column_exists?(:order_items, :return_deadline)
    remove_column :order_items, :return_requested if column_exists?(:order_items, :return_requested)
  end
end
