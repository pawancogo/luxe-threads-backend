# frozen_string_literal: true

module Admins
  module Reports
    class RevenueReportService < BaseReportService
      def call
        orders = orders_scope
        
        set_result({
          summary: calculate_revenue_summary(orders),
          daily_revenue: calculate_daily_revenue(orders),
          revenue_by_category: calculate_revenue_by_category(orders),
          revenue_by_payment_method: calculate_revenue_by_payment_method(orders),
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def orders_scope
        Order.where(created_at: date_range)
             .where(status: ['paid', 'shipped', 'delivered'])
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

        fill_missing_dates(stats_hash, { revenue: 0.0, orders_count: 0 })
      end

      def calculate_revenue_by_category(orders)
        OrderItem.joins(:product_variant => :product)
                 .joins('INNER JOIN orders ON orders.id = order_items.order_id')
                 .where(orders: { id: orders.select(:id) })
                 .group('products.category_id')
                 .joins('INNER JOIN categories ON categories.id = products.category_id')
                 .select('categories.name as category_name,
                         SUM(order_items.final_price * order_items.quantity) as revenue')
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
    end
  end
end

