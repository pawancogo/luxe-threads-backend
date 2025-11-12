# frozen_string_literal: true

module Admins
  module Reports
    class ProductsReportService < BaseReportService
      def call
        products = products_scope
        
        set_result({
          summary: calculate_products_summary(products),
          products_by_status: calculate_products_by_status(products),
          products_by_category: calculate_products_by_category(products),
          products_by_supplier: calculate_products_by_supplier(products),
          top_products: calculate_top_products_by_revenue,
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def products_scope
        Product.where(created_at: date_range)
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
        total = products.count
        products.group(:status).count.map do |status, count|
          {
            status: status,
            count: count,
            percentage: calculate_percentage(count, total)
          }
        end
      end

      def calculate_products_by_category(products)
        total = products.count
        products.joins(:category)
                .group('categories.name')
                .count
                .map do |category_name, count|
          {
            category_name: category_name,
            count: count,
            percentage: calculate_percentage(count, total)
          }
        end
      end

      def calculate_products_by_supplier(products)
        total = products.count
        products.joins(:supplier_profile)
                .group('supplier_profiles.company_name')
                .count
                .map do |supplier_name, count|
          {
            supplier_name: supplier_name,
            count: count,
            percentage: calculate_percentage(count, total)
          }
        end
      end

      def calculate_top_products_by_revenue(limit: 10)
        OrderItem.joins(:product_variant => :product)
                 .joins('INNER JOIN orders ON orders.id = order_items.order_id')
                 .where(orders: { created_at: date_range })
                 .where(orders: { status: ['paid', 'shipped', 'delivered'] })
                 .group('products.id', 'products.name')
                 .select('products.id, products.name,
                         SUM(order_items.final_price * order_items.quantity) as revenue,
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
    end
  end
end

