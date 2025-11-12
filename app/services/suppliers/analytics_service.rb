# frozen_string_literal: true

# Service for calculating supplier analytics from order items
module Suppliers
  class AnalyticsService
    attr_reader :supplier_profile, :start_date, :end_date, :errors

    def initialize(supplier_profile, start_date: nil, end_date: nil)
      @supplier_profile = supplier_profile
      @start_date = start_date || 30.days.ago.to_date
      @end_date = end_date || Date.current
      @errors = []
    end

    def call
      {
        summary: calculate_summary,
        daily_stats: calculate_daily_stats,
        top_products: calculate_top_products,
        sales_by_status: calculate_sales_by_status,
        returns_summary: calculate_returns_summary,
        period: {
          start_date: @start_date.iso8601,
          end_date: @end_date.iso8601
        }
      }
    rescue StandardError => e
      @errors << e.message
      Rails.logger.error "Suppliers::AnalyticsService failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      {}
    end

    private

    def order_items_scope
      OrderItem.where(supplier_profile_id: @supplier_profile.id)
               .joins(:order)
               .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
    end

    def calculate_summary
      items = order_items_scope
      delivered_items = items.where(fulfillment_status: 'delivered')
      returned_items = items.where(fulfillment_status: ['returned', 'refunded'])
      
      total_revenue = delivered_items.sum('(final_price * quantity)')
      total_orders = items.select('DISTINCT order_id').count
      total_items_sold = delivered_items.sum(:quantity)
      total_items_returned = returned_items.sum(:quantity)
      average_order_value = total_orders > 0 ? (total_revenue / total_orders) : 0
      return_rate = total_items_sold > 0 ? ((total_items_returned.to_f / total_items_sold) * 100) : 0

      {
        total_revenue: total_revenue.to_f.round(2),
        total_orders: total_orders,
        total_items_sold: total_items_sold,
        total_items_returned: total_items_returned,
        average_order_value: average_order_value.round(2),
        return_rate: return_rate.round(2),
        pending_orders: items.where(fulfillment_status: ['pending', 'processing', 'packed']).count,
        shipped_orders: items.where(fulfillment_status: 'shipped').count,
        delivered_orders: delivered_items.count
      }
    end

    def calculate_daily_stats
      items = order_items_scope
              .select("DATE(orders.created_at) as date, 
                      COUNT(DISTINCT orders.id) as orders_count,
                      SUM(CASE WHEN order_items.fulfillment_status = 'delivered' 
                               THEN (order_items.final_price * order_items.quantity) 
                               ELSE 0 END) as revenue,
                      SUM(CASE WHEN order_items.fulfillment_status = 'delivered' 
                               THEN order_items.quantity 
                               ELSE 0 END) as items_sold")
              .group("DATE(orders.created_at)")
              .order("DATE(orders.created_at)")

      stats_hash = {}
      items.each do |item|
        stats_hash[item.date.to_s] = {
          date: item.date.iso8601,
          orders_count: item.orders_count.to_i,
          revenue: item.revenue.to_f.round(2),
          items_sold: item.items_sold.to_i
        }
      end

      # Fill in missing dates with zeros
      (@start_date..@end_date).each do |date|
        date_str = date.to_s
        unless stats_hash[date_str]
          stats_hash[date_str] = {
            date: date.iso8601,
            orders_count: 0,
            revenue: 0.0,
            items_sold: 0
          }
        end
      end

      stats_hash.values.sort_by { |s| s[:date] }
    end

    def calculate_top_products(limit: 10)
      items = order_items_scope
              .where(fulfillment_status: 'delivered')
              .joins(product_variant: :product)
              .select("products.id as product_id,
                      products.name as product_name,
                      SUM(order_items.quantity) as total_quantity,
                      SUM(order_items.final_price * order_items.quantity) as total_revenue,
                      COUNT(DISTINCT order_items.order_id) as order_count")
              .group("products.id, products.name")
              .order("total_revenue DESC")
              .limit(limit)

      items.map do |item|
        {
          product_id: item.product_id,
          product_name: item.product_name,
          total_quantity: item.total_quantity.to_i,
          total_revenue: item.total_revenue.to_f.round(2),
          order_count: item.order_count.to_i
        }
      end
    end

    def calculate_sales_by_status
      items = order_items_scope
              .select("order_items.fulfillment_status,
                      COUNT(*) as item_count,
                      SUM(order_items.quantity) as total_quantity,
                      SUM(order_items.final_price * order_items.quantity) as total_revenue")
              .group("order_items.fulfillment_status")

      status_hash = {}
      items.each do |item|
        status_hash[item.fulfillment_status] = {
          status: item.fulfillment_status,
          item_count: item.item_count.to_i,
          total_quantity: item.total_quantity.to_i,
          total_revenue: item.total_revenue.to_f.round(2)
        }
      end

      # Ensure all statuses are present
      OrderItem.fulfillment_statuses.keys.each do |status|
        status_hash[status] ||= {
          status: status,
          item_count: 0,
          total_quantity: 0,
          total_revenue: 0.0
        }
      end

      status_hash.values
    end

    def calculate_returns_summary
      return_items = order_items_scope.where(fulfillment_status: ['returned', 'refunded'])
      
      total_returned = return_items.sum(:quantity)
      total_returned_value = return_items.sum('(final_price * quantity)')
      return_requests = ReturnRequest.joins(
        return_items: :order_item
      ).where(
        order_items: { 
          supplier_profile_id: @supplier_profile.id,
          fulfillment_status: ['returned', 'refunded']
        }
      ).where(
        created_at: @start_date.beginning_of_day..@end_date.end_of_day
      )

      {
        total_returned_items: total_returned,
        total_returned_value: total_returned_value.to_f.round(2),
        total_return_requests: return_requests.count,
        approved_returns: return_requests.where(status: 'approved').count,
        rejected_returns: return_requests.where(status: 'rejected').count,
        completed_returns: return_requests.where(status: 'completed').count
      }
    end
  end
end

