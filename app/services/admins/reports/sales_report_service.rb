# frozen_string_literal: true

module Admins
  module Reports
    class SalesReportService < BaseReportService
      def call
        orders = orders_scope
        
        set_result({
          summary: calculate_sales_summary(orders),
          daily_stats: calculate_daily_sales_stats(orders),
          sales_by_status: calculate_sales_by_status(orders),
          sales_by_category: calculate_sales_by_category(orders),
          sales_by_supplier: calculate_sales_by_supplier(orders),
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def orders_scope
        Order.where(created_at: date_range)
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

        fill_missing_dates(stats_hash, { orders_count: 0, revenue: 0.0 })
      end

      def calculate_sales_by_status(orders)
        total = orders.count
        orders.group(:status).count.map do |status, count|
          {
            status: status,
            count: count,
            percentage: calculate_percentage(count, total)
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
                         SUM(order_items.final_price * order_items.quantity) as revenue')
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
    end
  end
end

