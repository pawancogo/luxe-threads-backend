# frozen_string_literal: true

# Service for calculating admin/platform-wide analytics and reports
class AdminReportsService
  attr_reader :start_date, :end_date, :errors

  def initialize(start_date: nil, end_date: nil)
    @start_date = start_date || 30.days.ago.to_date
    @end_date = end_date || Date.current
    @errors = []
  end

  def sales_report
    orders = orders_scope
    
    {
      summary: calculate_sales_summary(orders),
      daily_stats: calculate_daily_sales_stats(orders),
      sales_by_status: calculate_sales_by_status(orders),
      sales_by_category: calculate_sales_by_category(orders),
      sales_by_supplier: calculate_sales_by_supplier(orders),
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#sales_report failed: #{e.message}"
    {}
  end

  def products_report
    products = products_scope
    
    {
      summary: calculate_products_summary(products),
      products_by_status: calculate_products_by_status(products),
      products_by_category: calculate_products_by_category(products),
      products_by_supplier: calculate_products_by_supplier(products),
      top_products: calculate_top_products_by_revenue,
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#products_report failed: #{e.message}"
    {}
  end

  def users_report
    users = users_scope
    
    {
      summary: calculate_users_summary(users),
      users_by_role: calculate_users_by_role(users),
      new_users_daily: calculate_new_users_daily(users),
      users_activity: calculate_users_activity(users),
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#users_report failed: #{e.message}"
    {}
  end

  def suppliers_report
    suppliers = suppliers_scope
    
    {
      summary: calculate_suppliers_summary(suppliers),
      suppliers_by_tier: calculate_suppliers_by_tier(suppliers),
      suppliers_performance: calculate_suppliers_performance(suppliers),
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#suppliers_report failed: #{e.message}"
    {}
  end

  def revenue_report
    orders = orders_scope.where(status: ['paid', 'shipped', 'delivered'])
    
    {
      summary: calculate_revenue_summary(orders),
      daily_revenue: calculate_daily_revenue(orders),
      revenue_by_category: calculate_revenue_by_category(orders),
      revenue_by_payment_method: calculate_revenue_by_payment_method(orders),
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#revenue_report failed: #{e.message}"
    {}
  end

  def returns_report
    return_requests = return_requests_scope
    
    {
      summary: calculate_returns_summary(return_requests),
      returns_by_status: calculate_returns_by_status(return_requests),
      returns_by_reason: calculate_returns_by_reason(return_requests),
      daily_returns: calculate_daily_returns(return_requests),
      period: {
        start_date: @start_date.iso8601,
        end_date: @end_date.iso8601
      }
    }
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "AdminReportsService#returns_report failed: #{e.message}"
    {}
  end

  private

  def orders_scope
    Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  end

  def products_scope
    Product.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  end

  def users_scope
    User.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  end

  def suppliers_scope
    User.where(role: 'supplier').where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  end

  def return_requests_scope
    ReturnRequest.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
  end

  def calculate_sales_summary(orders)
    completed_orders = orders.where(status: ['paid', 'shipped', 'delivered'])
    total_revenue = completed_orders.sum(:total_amount)
    total_orders = orders.count
    completed_orders_count = completed_orders.count
    average_order_value = completed_orders_count > 0 ? (total_revenue / completed_orders_count) : 0
    
    {
      total_revenue: total_revenue.to_f.round(2),
      total_orders: total_orders,
      completed_orders: completed_orders_count,
      cancelled_orders: orders.where(status: 'cancelled').count,
      average_order_value: average_order_value.round(2),
      pending_orders: orders.where(status: 'pending').count,
      shipped_orders: orders.where(status: 'shipped').count,
      delivered_orders: orders.where(status: 'delivered').count
    }
  end

  def calculate_daily_sales_stats(orders)
    stats = orders
      .select("DATE(created_at) as date, 
               COUNT(*) as orders_count,
               SUM(CASE WHEN status IN ('paid', 'shipped', 'delivered') THEN total_amount ELSE 0 END) as revenue")
      .group("DATE(created_at)")
      .order("DATE(created_at)")

    stats_hash = {}
    stats.each do |stat|
      stats_hash[stat.date.to_s] = {
        date: stat.date.iso8601,
        orders_count: stat.orders_count.to_i,
        revenue: stat.revenue.to_f.round(2)
      }
    end

    # Fill in missing dates
    (@start_date..@end_date).each do |date|
      date_str = date.to_s
      unless stats_hash[date_str]
        stats_hash[date_str] = {
          date: date.iso8601,
          orders_count: 0,
          revenue: 0.0
        }
      end
    end

    stats_hash.values.sort_by { |s| s[:date] }
  end

  def calculate_sales_by_status(orders)
    orders.group(:status).count.map do |status, count|
      {
        status: status,
        count: count,
        percentage: orders.count > 0 ? ((count.to_f / orders.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_sales_by_category(orders)
    OrderItem.joins(:product_variant => :product)
             .joins('INNER JOIN orders ON orders.id = order_items.order_id')
             .where(orders: { id: orders.select(:id) })
             .group('products.category_id')
             .joins('INNER JOIN categories ON categories.id = products.category_id')
             .select('categories.name as category_name, 
                     COUNT(DISTINCT order_items.order_id) as orders_count,
                     SUM(order_items.price * order_items.quantity) as revenue')
             .map do |item|
      {
        category_name: item.category_name,
        orders_count: item.orders_count.to_i,
        revenue: item.revenue.to_f.round(2)
      }
    end
  end

  def calculate_sales_by_supplier(orders)
    OrderItem.joins(:supplier_profile)
             .joins('INNER JOIN orders ON orders.id = order_items.order_id')
             .where(orders: { id: orders.select(:id) })
             .group('supplier_profiles.id')
             .select('supplier_profiles.company_name,
                     COUNT(DISTINCT order_items.order_id) as orders_count,
                     SUM(order_items.final_price * order_items.quantity) as revenue')
             .limit(10)
             .map do |item|
      {
        supplier_name: item.company_name,
        orders_count: item.orders_count.to_i,
        revenue: item.revenue.to_f.round(2)
      }
    end
  end

  def calculate_products_summary(products)
    {
      total_products: products.count,
      active_products: products.where(status: 'active').count,
      pending_products: products.where(status: 'pending').count,
      rejected_products: products.where(status: 'rejected').count,
      featured_products: products.where(is_featured: true).count,
      low_stock_products: Product.joins(:product_variants)
                                  .where(product_variants: { is_low_stock: true })
                                  .distinct
                                  .count
    }
  end

  def calculate_products_by_status(products)
    products.group(:status).count.map do |status, count|
      {
        status: status,
        count: count,
        percentage: products.count > 0 ? ((count.to_f / products.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_products_by_category(products)
    products.joins(:category)
            .group('categories.name')
            .count
            .map do |category_name, count|
      {
        category_name: category_name,
        count: count,
        percentage: products.count > 0 ? ((count.to_f / products.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_products_by_supplier(products)
    products.joins(:supplier_profile)
            .group('supplier_profiles.company_name')
            .count
            .map do |supplier_name, count|
      {
        supplier_name: supplier_name,
        count: count,
        percentage: products.count > 0 ? ((count.to_f / products.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_top_products_by_revenue(limit: 10)
    OrderItem.joins(:product_variant => :product)
             .joins('INNER JOIN orders ON orders.id = order_items.order_id')
             .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
             .where(orders: { status: ['paid', 'shipped', 'delivered'] })
             .group('products.id', 'products.name')
             .select('products.id, products.name,
                     SUM(order_items.price * order_items.quantity) as revenue,
                     SUM(order_items.quantity) as quantity_sold,
                     COUNT(DISTINCT order_items.order_id) as orders_count')
             .order('revenue DESC')
             .limit(limit)
             .map do |item|
      {
        product_id: item.id,
        product_name: item.name,
        revenue: item.revenue.to_f.round(2),
        quantity_sold: item.quantity_sold.to_i,
        orders_count: item.orders_count.to_i
      }
    end
  end

  def calculate_users_summary(users)
    {
      total_users: users.count,
      customers: users.where.not(role: 'supplier').count,
      suppliers: users.where(role: 'supplier').count,
      active_users: users.where(deleted_at: nil).count,
      inactive_users: users.where.not(deleted_at: nil).count
    }
  end

  def calculate_users_by_role(users)
    users.group(:role).count.map do |role, count|
      {
        role: role,
        count: count,
        percentage: users.count > 0 ? ((count.to_f / users.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_new_users_daily(users)
    stats = users.select("DATE(created_at) as date, COUNT(*) as count")
                 .group("DATE(created_at)")
                 .order("DATE(created_at)")

    stats_hash = {}
    stats.each do |stat|
      stats_hash[stat.date.to_s] = {
        date: stat.date.iso8601,
        count: stat.count.to_i
      }
    end

    # Fill in missing dates
    (@start_date..@end_date).each do |date|
      date_str = date.to_s
      unless stats_hash[date_str]
        stats_hash[date_str] = {
          date: date.iso8601,
          count: 0
        }
      end
    end

    stats_hash.values.sort_by { |s| s[:date] }
  end

  def calculate_users_activity(users)
    # Users with orders in the period
    active_users = User.joins(:orders)
                      .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                      .distinct
                      .count

    {
      active_users: active_users,
      inactive_users: users.count - active_users
    }
  end

  def calculate_suppliers_summary(suppliers)
    {
      total_suppliers: suppliers.count,
      verified_suppliers: suppliers.joins(:supplier_profile)
                                   .where(supplier_profiles: { verified: true })
                                   .count,
      active_suppliers: suppliers.where(deleted_at: nil).count
    }
  end

  def calculate_suppliers_by_tier(suppliers)
    suppliers.joins(:supplier_profile)
             .group('supplier_profiles.supplier_tier')
             .count
             .map do |tier, count|
      {
        tier: tier || 'standard',
        count: count
      }
    end
  end

  def calculate_suppliers_performance(suppliers)
    suppliers.joins(:supplier_profile)
             .left_joins(supplier_profile: { products: { product_variants: :order_items } })
             .joins('LEFT JOIN orders ON orders.id = order_items.order_id')
             .where('orders.created_at IS NULL OR orders.created_at >= ?', @start_date.beginning_of_day)
             .where('orders.created_at IS NULL OR orders.created_at <= ?', @end_date.end_of_day)
             .group('supplier_profiles.id', 'supplier_profiles.company_name')
             .select('supplier_profiles.id, supplier_profiles.company_name,
                     COUNT(DISTINCT orders.id) as orders_count,
                     SUM(CASE WHEN orders.status IN (\'paid\', \'shipped\', \'delivered\') 
                              THEN (order_items.final_price * order_items.quantity) 
                              ELSE 0 END) as revenue')
             .order('revenue DESC')
             .limit(10)
             .map do |item|
      {
        supplier_id: item.id,
        supplier_name: item.company_name,
        orders_count: item.orders_count.to_i,
        revenue: item.revenue.to_f.round(2)
      }
    end
  end

  def calculate_revenue_summary(orders)
    total_revenue = orders.sum(:total_amount)
    total_orders = orders.count
    average_order_value = total_orders > 0 ? (total_revenue / total_orders) : 0
    
    {
      total_revenue: total_revenue.to_f.round(2),
      total_orders: total_orders,
      average_order_value: average_order_value.round(2),
      currency: 'INR'
    }
  end

  def calculate_daily_revenue(orders)
    stats = orders.select("DATE(created_at) as date, SUM(total_amount) as revenue, COUNT(*) as orders_count")
                  .group("DATE(created_at)")
                  .order("DATE(created_at)")

    stats_hash = {}
    stats.each do |stat|
      stats_hash[stat.date.to_s] = {
        date: stat.date.iso8601,
        revenue: stat.revenue.to_f.round(2),
        orders_count: stat.orders_count.to_i
      }
    end

    # Fill in missing dates
    (@start_date..@end_date).each do |date|
      date_str = date.to_s
      unless stats_hash[date_str]
        stats_hash[date_str] = {
          date: date.iso8601,
          revenue: 0.0,
          orders_count: 0
        }
      end
    end

    stats_hash.values.sort_by { |s| s[:date] }
  end

  def calculate_revenue_by_category(orders)
    OrderItem.joins(:product_variant => :product)
             .joins('INNER JOIN orders ON orders.id = order_items.order_id')
             .where(orders: { id: orders.select(:id) })
             .group('products.category_id')
             .joins('INNER JOIN categories ON categories.id = products.category_id')
             .select('categories.name as category_name,
                     SUM(order_items.price * order_items.quantity) as revenue')
             .map do |item|
      {
        category_name: item.category_name,
        revenue: item.revenue.to_f.round(2)
      }
    end
  end

  def calculate_revenue_by_payment_method(orders)
    orders.group(:payment_method)
          .select('payment_method, SUM(total_amount) as revenue, COUNT(*) as orders_count')
          .map do |item|
      {
        payment_method: item.payment_method || 'unknown',
        revenue: item.revenue.to_f.round(2),
        orders_count: item.orders_count.to_i
      }
    end
  end

  def calculate_returns_summary(return_requests)
    {
      total_returns: return_requests.count,
      approved_returns: return_requests.where(status: 'approved').count,
      rejected_returns: return_requests.where(status: 'rejected').count,
      completed_returns: return_requests.where(status: 'completed').count,
      total_refund_amount: return_requests.where.not(refund_amount: nil).sum(:refund_amount).to_f.round(2)
    }
  end

  def calculate_returns_by_status(return_requests)
    return_requests.group(:status).count.map do |status, count|
      {
        status: status,
        count: count,
        percentage: return_requests.count > 0 ? ((count.to_f / return_requests.count) * 100).round(2) : 0
      }
    end
  end

  def calculate_returns_by_reason(return_requests)
    # Group by items with return reason
    return_requests.joins(:return_request_items)
                   .group('return_request_items.reason')
                   .count
                   .map do |reason, count|
      {
        reason: reason || 'not_specified',
        count: count
      }
    end
  end

  def calculate_daily_returns(return_requests)
    stats = return_requests.select("DATE(created_at) as date, COUNT(*) as count")
                            .group("DATE(created_at)")
                            .order("DATE(created_at)")

    stats_hash = {}
    stats.each do |stat|
      stats_hash[stat.date.to_s] = {
        date: stat.date.iso8601,
        count: stat.count.to_i
      }
    end

    # Fill in missing dates
    (@start_date..@end_date).each do |date|
      date_str = date.to_s
      unless stats_hash[date_str]
        stats_hash[date_str] = {
          date: date.iso8601,
          count: 0
        }
      end
    end

    stats_hash.values.sort_by { |s| s[:date] }
  end
end

