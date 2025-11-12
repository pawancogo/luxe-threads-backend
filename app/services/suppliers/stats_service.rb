# frozen_string_literal: true

# Service for calculating supplier statistics
module Suppliers
  class StatsService < BaseService
    attr_reader :stats

    def initialize(supplier)
      super()
      @supplier = supplier
    end

    def call
      calculate_stats
      set_result(@stats)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def calculate_stats
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      unless profile
        add_error('Supplier profile not found')
        raise StandardError, 'Supplier profile not found'
      end

      @stats = {
        total_products: profile.products.count,
        active_products: profile.products.where(status: 'active').count,
        pending_products: profile.products.where(status: 'pending').count,
        total_orders: calculate_total_orders(profile),
        total_revenue: calculate_total_revenue(profile),
        verified: profile.verified || false,
        supplier_tier: profile.supplier_tier || 'basic',
        created_at: @supplier.created_at
      }
    end

    def calculate_total_orders(profile)
      profile.products.joins(product_variants: :order_items)
                       .distinct
                       .count('order_items.order_id')
    end

    def calculate_total_revenue(profile)
      profile.products.joins(product_variants: { order_items: :order })
                       .where(orders: { status: ['paid', 'shipped', 'delivered'] })
                       .sum('order_items.final_price * order_items.quantity')
    end
  end
end

