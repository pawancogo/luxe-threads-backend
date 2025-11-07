# frozen_string_literal: true

namespace :data do
  desc "Master data migration script - runs all data migrations"
  task migrate: :environment do
    puts "=" * 80
    puts "Starting Master Data Migration"
    puts "=" * 80
    
    begin
      # Note: Supplier migration is optional (only if suppliers table exists)
      if ActiveRecord::Base.connection.table_exists?('suppliers')
        Rake::Task['data:migrate_suppliers'].invoke
      end
      Rake::Task['data:migrate_products'].invoke
      Rake::Task['data:migrate_orders'].invoke
      Rake::Task['data:calculate_metrics'].invoke
      
      puts ""
      puts "=" * 80
      puts "✅ All data migrations completed successfully!"
      puts "=" * 80
    rescue => e
      puts ""
      puts "=" * 80
      puts "❌ Error during data migration: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      puts "=" * 80
      raise
    end
  end
  
  desc "Calculate and cache all metrics (ratings, counts, etc.)"
  task calculate_metrics: :environment do
    puts "Calculating metrics..."
    
    # Calculate product ratings
    puts "  - Calculating product ratings..."
    Product.find_each do |product|
      # Use where clause in case approved scope doesn't exist
      reviews = product.reviews.where(moderation_status: 'approved')
      if reviews.any?
        avg_rating = reviews.average(:rating).to_f.round(2)
        total_reviews = reviews.count
        rating_distribution = reviews.group(:rating).count
        
        product.update_columns(
          average_rating: avg_rating,
          total_reviews: total_reviews,
          rating_distribution: rating_distribution.to_json
        )
      end
    end
    
    # Calculate category product counts
    puts "  - Calculating category product counts..."
    Category.find_each do |category|
      products_count = category.products.active.count
      category.update_column(:products_count, products_count)
    end
    
    # Calculate brand product counts
    puts "  - Calculating brand product counts..."
    Brand.find_each do |brand|
      products_count = brand.products.active.count
      brand.update_column(:products_count, products_count)
    end
    
    # Reset counter caches
    puts "  - Resetting counter caches..."
    User.find_each { |user| User.reset_counters(user.id, :orders) }
    
    puts "✅ Metrics calculation completed!"
  end
  
  desc "Validate data integrity"
  task validate: :environment do
    puts "=" * 80
    puts "Starting Data Validation"
    puts "=" * 80
    
    errors = []
    
    # Check referential integrity
    puts "Checking referential integrity..."
    
    # Check orphaned order items
    orphaned_order_items = OrderItem.where.not(order_id: Order.select(:id))
    if orphaned_order_items.any?
      errors << "Found #{orphaned_order_items.count} orphaned order items"
    end
    
    # Check orphaned cart items
    orphaned_cart_items = CartItem.where.not(cart_id: Cart.select(:id))
    if orphaned_cart_items.any?
      errors << "Found #{orphaned_cart_items.count} orphaned cart items"
    end
    
    # Check orphaned wishlist items
    orphaned_wishlist_items = WishlistItem.where.not(wishlist_id: Wishlist.select(:id))
    if orphaned_wishlist_items.any?
      errors << "Found #{orphaned_wishlist_items.count} orphaned wishlist items"
    end
    
    # Check products without supplier
    products_without_supplier = Product.where.not(supplier_profile_id: SupplierProfile.select(:id))
    if products_without_supplier.any?
      errors << "Found #{products_without_supplier.count} products without supplier"
    end
    
    # Check product variants without product
    variants_without_product = ProductVariant.where.not(product_id: Product.select(:id))
    if variants_without_product.any?
      errors << "Found #{variants_without_product.count} product variants without product"
    end
    
    # Data consistency checks
    puts "Checking data consistency..."
    
    # Check orders with invalid status
    invalid_orders = Order.where.not(status: Order.statuses.keys)
    if invalid_orders.any?
      errors << "Found #{invalid_orders.count} orders with invalid status"
    end
    
    # Check negative stock quantities
    negative_stock = ProductVariant.where('stock_quantity < 0')
    if negative_stock.any?
      errors << "Found #{negative_stock.count} product variants with negative stock"
    end
    
    # Check orders with zero total
    zero_total_orders = Order.where('total_amount <= 0')
    if zero_total_orders.any?
      errors << "Found #{zero_total_orders.count} orders with zero or negative total"
    end
    
    # Report results
    puts ""
    if errors.empty?
      puts "✅ All data validation checks passed!"
    else
      puts "❌ Found #{errors.count} validation issues:"
      errors.each { |error| puts "  - #{error}" }
    end
    
    puts "=" * 80
  end
end

