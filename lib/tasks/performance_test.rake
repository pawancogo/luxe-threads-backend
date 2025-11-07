# frozen_string_literal: true

namespace :performance do
  desc "Run performance benchmarks on common queries"
  task benchmark: :environment do
    require 'benchmark'
    
    puts "=" * 80
    puts "Performance Benchmarks"
    puts "=" * 80
    puts ""
    
    # Benchmark orders query
    puts "Benchmarking: Orders by user and status"
    user = User.first || create(:user)
    create_list(:order, 100, user: user) unless user.orders.any?
    
    time = Benchmark.realtime do
      100.times do
        Order.where(user_id: user.id, status: 'pending').order(created_at: :desc).to_a
      end
    end
    puts "  Time: #{(time * 1000).round(2)}ms for 100 queries"
    puts "  Avg: #{(time / 100 * 1000).round(2)}ms per query"
    puts ""
    
    # Benchmark products query
    puts "Benchmarking: Active products by category"
    category = Category.first || create(:category)
    create_list(:product, 100, category: category, status: 'active') unless category.products.active.any?
    
    time = Benchmark.realtime do
      100.times do
        Product.where(category_id: category.id, status: 'active').to_a
      end
    end
    puts "  Time: #{(time * 1000).round(2)}ms for 100 queries"
    puts "  Avg: #{(time / 100 * 1000).round(2)}ms per query"
    puts ""
    
    # Benchmark notifications query
    puts "Benchmarking: Unread notifications"
    user = User.first
    create_list(:notification, 100, user: user, is_read: false) unless user.notifications.where(is_read: false).any?
    
    time = Benchmark.realtime do
      100.times do
        Notification.where(user_id: user.id, is_read: false).order(created_at: :desc).to_a
      end
    end
    puts "  Time: #{(time * 1000).round(2)}ms for 100 queries"
    puts "  Avg: #{(time / 100 * 1000).round(2)}ms per query"
    puts ""
    
    puts "=" * 80
    puts "Benchmarks completed!"
    puts "=" * 80
  end
  
  desc "Analyze query performance with EXPLAIN"
  task analyze_queries: :environment do
    puts "=" * 80
    puts "Query Performance Analysis"
    puts "=" * 80
    puts ""
    
    # Analyze orders query
    puts "Analyzing: Orders by user and status"
    user = User.first
    if user
      query = Order.where(user_id: user.id, status: 'pending').order(created_at: :desc)
      puts ActiveRecord::Base.connection.explain(query.to_sql)
      puts ""
    end
    
    # Analyze products query
    puts "Analyzing: Active products by category"
    category = Category.first
    if category
      query = Product.where(category_id: category.id, status: 'active')
      puts ActiveRecord::Base.connection.explain(query.to_sql)
      puts ""
    end
  end
end

