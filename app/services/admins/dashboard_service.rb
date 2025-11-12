# frozen_string_literal: true

# Service for calculating admin dashboard statistics
module Admins
  class DashboardService < BaseService
    attr_reader :stats, :revenue_metrics, :daily_revenue, :revenue_by_category, :recent_orders, :recent_products, :recent_users

    def initialize(start_date: nil, end_date: nil)
      super()
      @start_date = start_date || 30.days.ago.to_date
      @end_date = end_date || Date.current
    end

    def call
      calculate_stats
      calculate_revenue_metrics
      calculate_daily_revenue
      calculate_revenue_by_category
      load_recent_records
      set_result(build_result)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def calculate_stats
      user_stats = User.group(:role).count
      product_stats = Product.group(:status).count
      
      @stats = {
        total_users: user_stats.except('supplier').values.sum,
        total_suppliers: user_stats['supplier'] || 0,
        total_products: Product.count,
        pending_products: product_stats['pending'] || 0,
        active_products: product_stats['active'] || 0,
        total_orders: Order.count,
        pending_orders: Order.group(:status).count['pending'] || 0,
        shipped_orders: Order.group(:status).count['shipped'] || 0,
        featured_products: Product.where(is_featured: true).count,
        low_stock_variants: ProductVariant.where(is_low_stock: true).count,
        out_of_stock_variants: ProductVariant.where(out_of_stock: true).count,
        categories_count: Category.count
      }
    end

    def calculate_revenue_metrics
      completed_orders_scope = Order.where(status: ['paid', 'shipped', 'delivered'])
                                     .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      
      revenue_stats = completed_orders_scope.select('SUM(total_amount) as total_revenue, COUNT(*) as total_orders').first
      total_revenue = revenue_stats&.total_revenue&.to_f || 0.0
      total_orders_count = revenue_stats&.total_orders&.to_i || 0
      
      @revenue_metrics = {
        total_revenue: total_revenue.round(2),
        total_orders: total_orders_count,
        average_order_value: total_orders_count > 0 ? (total_revenue / total_orders_count).round(2) : 0,
        currency: 'INR'
      }
    end

    def calculate_daily_revenue
      orders = Order.where(status: ['paid', 'shipped', 'delivered'])
                    .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      
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
      
      @daily_revenue = stats_hash.values.sort_by { |s| s[:date] }
    end

    def calculate_revenue_by_category
      @revenue_by_category = OrderItem.joins(:product_variant => :product, :order => [])
                                      .joins('INNER JOIN categories ON categories.id = products.category_id')
                                      .where(orders: { 
                                        status: ['paid', 'shipped', 'delivered'],
                                        created_at: @start_date.beginning_of_day..@end_date.end_of_day
                                      })
                                      .group('categories.id', 'categories.name')
                                      .select('categories.name as category_name,
                                              SUM(order_items.final_price * order_items.quantity) as revenue')
                                      .map do |item|
        {
          category_name: item.category_name,
          revenue: item.revenue.to_f.round(2)
        }
      end
    end

    def load_recent_records
      @recent_orders = Order.includes(:user).order(created_at: :desc).limit(10)
      @recent_products = Product.includes(:supplier_profile, :category, :brand).order(created_at: :desc).limit(10)
      @recent_users = User.where.not(role: 'supplier').includes(:addresses).order(created_at: :desc).limit(10)
    end

    def build_result
      {
        stats: @stats,
        revenue_metrics: @revenue_metrics,
        daily_revenue: @daily_revenue,
        revenue_by_category: @revenue_by_category,
        recent_orders: @recent_orders,
        recent_products: @recent_products,
        recent_users: @recent_users
      }
    end
  end
end

