# frozen_string_literal: true

class AddPerformanceIndexesPhase5 < ActiveRecord::Migration[7.1]
  def change
    # Composite indexes for common query patterns
    
    # Orders - by user and status
    add_index :orders, [:user_id, :status, :created_at], 
      name: 'index_orders_on_user_status_created' unless index_exists?(:orders, [:user_id, :status, :created_at])
    
    # Orders - by status and created_at (for admin queries)
    add_index :orders, [:status, :created_at], 
      name: 'index_orders_on_status_created' unless index_exists?(:orders, [:status, :created_at])
    
    # Order Items - by supplier and status
    add_index :order_items, [:supplier_profile_id, :fulfillment_status, :created_at],
      name: 'index_order_items_on_supplier_status_created' unless index_exists?(:order_items, [:supplier_profile_id, :fulfillment_status, :created_at])
    
    # Products - by supplier and status
    add_index :products, [:supplier_profile_id, :status, :created_at],
      name: 'index_products_on_supplier_status_created' unless index_exists?(:products, [:supplier_profile_id, :status, :created_at])
    
    # Products - by category and status
    add_index :products, [:category_id, :status],
      name: 'index_products_on_category_status' unless index_exists?(:products, [:category_id, :status])
    
    # Product Variants - by product and availability
    add_index :product_variants, [:product_id, :is_available, :stock_quantity],
      name: 'index_variants_on_product_available_stock' unless index_exists?(:product_variants, [:product_id, :is_available, :stock_quantity])
    
    # Reviews - by product and moderation status
    add_index :reviews, [:product_id, :moderation_status, :created_at],
      name: 'index_reviews_on_product_moderation_created' unless index_exists?(:reviews, [:product_id, :moderation_status, :created_at])
    
    # Reviews - by user and product (for uniqueness checks)
    add_index :reviews, [:user_id, :product_id],
      name: 'index_reviews_on_user_product' unless index_exists?(:reviews, [:user_id, :product_id])
    
    # Cart Items - by cart and created_at
    add_index :cart_items, [:cart_id, :created_at],
      name: 'index_cart_items_on_cart_created' unless index_exists?(:cart_items, [:cart_id, :created_at])
    
    # Wishlist Items - by wishlist and created_at
    add_index :wishlist_items, [:wishlist_id, :created_at],
      name: 'index_wishlist_items_on_wishlist_created' unless index_exists?(:wishlist_items, [:wishlist_id, :created_at])
    
    # Addresses - by user and type
    add_index :addresses, [:user_id, :address_type],
      name: 'index_addresses_on_user_type' unless index_exists?(:addresses, [:user_id, :address_type])
    
    # Return Requests - by order and status
    add_index :return_requests, [:order_id, :status, :created_at],
      name: 'index_return_requests_on_order_status_created' unless index_exists?(:return_requests, [:order_id, :status, :created_at])
    
    # Payments - by order and status
    add_index :payments, [:order_id, :status, :created_at],
      name: 'index_payments_on_order_status_created' unless index_exists?(:payments, [:order_id, :status, :created_at])
    
    # Shipments - by order and status
    add_index :shipments, [:order_id, :status, :created_at],
      name: 'index_shipments_on_order_status_created' unless index_exists?(:shipments, [:order_id, :status, :created_at])
    
    # Partial indexes for filtered queries
    
    # Active products only
    add_index :products, [:category_id, :created_at],
      name: 'index_active_products_on_category_created',
      where: "status = 'active'",
      if_not_exists: true unless index_exists?(:products, [:category_id, :created_at], name: 'index_active_products_on_category_created')
    
    # Available product variants only
    add_index :product_variants, [:product_id, :price],
      name: 'index_available_variants_on_product_price',
      where: "is_available = true AND stock_quantity > 0",
      if_not_exists: true
    
    # Unread notifications only
    add_index :notifications, [:user_id, :created_at],
      name: 'index_unread_notifications_on_user_created',
      where: "is_read = false",
      if_not_exists: true
    
    # GIN indexes for JSONB columns (PostgreSQL only)
    if connection.adapter_name == 'PostgreSQL'
      # User notification preferences
      if column_exists?(:users, :notification_preferences)
        add_index :users, :notification_preferences, 
          using: :gin, 
          name: 'index_users_on_notification_preferences_gin',
          if_not_exists: true unless index_exists?(:users, :notification_preferences, name: 'index_users_on_notification_preferences_gin')
      end
      
      # Order status history
      if column_exists?(:orders, :status_history)
        add_index :orders, :status_history,
          using: :gin,
          name: 'index_orders_on_status_history_gin',
          if_not_exists: true unless index_exists?(:orders, :status_history, name: 'index_orders_on_status_history_gin')
      end
      
      # Product highlights
      if column_exists?(:products, :highlights)
        add_index :products, :highlights,
          using: :gin,
          name: 'index_products_on_highlights_gin',
          if_not_exists: true unless index_exists?(:products, :highlights, name: 'index_products_on_highlights_gin')
      end
      
      # Product tags
      if column_exists?(:products, :tags)
        add_index :products, :tags,
          using: :gin,
          name: 'index_products_on_tags_gin',
          if_not_exists: true unless index_exists?(:products, :tags, name: 'index_products_on_tags_gin')
      end
      
      # Product search keywords
      if column_exists?(:products, :search_keywords)
        add_index :products, :search_keywords,
          using: :gin,
          name: 'index_products_on_search_keywords_gin',
          if_not_exists: true unless index_exists?(:products, :search_keywords, name: 'index_products_on_search_keywords_gin')
      end
      
      # User searches filters
      if column_exists?(:user_searches, :filters)
        add_index :user_searches, :filters,
          using: :gin,
          name: 'index_user_searches_on_filters_gin',
          if_not_exists: true unless index_exists?(:user_searches, :filters, name: 'index_user_searches_on_filters_gin')
      end
      
      # Notification data
      if column_exists?(:notifications, :data)
        add_index :notifications, :data,
          using: :gin,
          name: 'index_notifications_on_data_gin',
          if_not_exists: true unless index_exists?(:notifications, :data, name: 'index_notifications_on_data_gin')
      end
    end
    
    # Indexes for frequently queried columns
    
    # Product slugs (for SEO-friendly URLs)
    add_index :products, :slug, unique: true,
      name: 'index_products_on_slug_unique',
      if_not_exists: true unless index_exists?(:products, :slug, unique: true)
    
    # Category slugs
    add_index :categories, :slug, unique: true,
      name: 'index_categories_on_slug_unique',
      if_not_exists: true unless index_exists?(:categories, :slug, unique: true)
    
    # Brand slugs
    add_index :brands, :slug, unique: true,
      name: 'index_brands_on_slug_unique',
      if_not_exists: true unless index_exists?(:brands, :slug, unique: true)
    
    # Order numbers (for quick lookups)
    add_index :orders, :order_number, unique: true,
      name: 'index_orders_on_order_number_unique',
      if_not_exists: true unless index_exists?(:orders, :order_number, unique: true)
    
    # User emails (should already exist, but ensure it)
    add_index :users, :email, unique: true,
      name: 'index_users_on_email_unique',
      if_not_exists: true unless index_exists?(:users, :email, unique: true)
    
    # Soft delete indexes (for active records queries)
    add_index :users, :deleted_at,
      name: 'index_users_on_deleted_at' unless index_exists?(:users, :deleted_at)
    
    add_index :products, :deleted_at,
      name: 'index_products_on_deleted_at' unless index_exists?(:products, :deleted_at)
    
    add_index :orders, :deleted_at,
      name: 'index_orders_on_deleted_at' unless index_exists?(:orders, :deleted_at)
  end
end

