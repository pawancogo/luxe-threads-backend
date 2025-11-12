# frozen_string_literal: true

module Admins
  module Reports
    class SuppliersReportService < BaseReportService
      def call
        suppliers = suppliers_scope
        
        set_result({
          summary: calculate_suppliers_summary(suppliers),
          suppliers_by_tier: calculate_suppliers_by_tier(suppliers),
          suppliers_performance: calculate_suppliers_performance(suppliers),
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def suppliers_scope
        User.where(role: 'supplier').where(created_at: date_range)
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
    end
  end
end

