# frozen_string_literal: true

# Service for calculating user statistics
module Users
  class StatisticsService < BaseService
    attr_reader :stats

    def initialize(user)
      super()
      @user = user
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
      @stats = {
        orders: calculate_order_stats,
        addresses: calculate_address_stats,
        cart: calculate_cart_stats,
        wishlist: calculate_wishlist_stats,
        reviews: calculate_review_stats,
        loyalty_points: calculate_loyalty_stats,
        referrals: calculate_referral_stats,
        notifications: calculate_notification_stats
      }
    end

    def calculate_order_stats
      orders = @user.orders
      {
        total: orders.count,
        pending: orders.where(status: 'pending').count,
        confirmed: orders.where(status: 'confirmed').count,
        shipped: orders.where(status: 'shipped').count,
        delivered: orders.where(status: 'delivered').count,
        cancelled: orders.where(status: 'cancelled').count,
        total_spent: orders.sum(:total_amount) || 0.0
      }
    end

    def calculate_address_stats
      addresses = @user.addresses
      {
        total: addresses.count,
        shipping: addresses.where(is_default_shipping: true).count,
        billing: addresses.where(is_default_billing: true).count
      }
    end

    def calculate_cart_stats
      cart = @user.cart
      return { items_count: 0, total_value: 0.0 } unless cart

      {
        items_count: cart.cart_items.sum(:quantity) || 0,
        total_value: calculate_cart_total(cart)
      }
    end

    def calculate_cart_total(cart)
      cart.cart_items.includes(:product_variant).sum do |item|
        (item.product_variant.discounted_price || item.product_variant.price) * item.quantity
      end
    end

    def calculate_wishlist_stats
      wishlist = @user.wishlist
      {
        items_count: wishlist&.wishlist_items&.count || 0
      }
    end

    def calculate_review_stats
      reviews = @user.reviews
      {
        total: reviews.count,
        approved: reviews.where(moderation_status: 'approved').count,
        pending: reviews.where(moderation_status: 'pending').count
      }
    end

    def calculate_loyalty_stats
      # TODO: Implement when loyalty points system is added
      { total: 0, available: 0, used: 0 }
    end

    def calculate_referral_stats
      # TODO: Implement when referral system is added
      { total_referrals: 0, successful_referrals: 0 }
    end

    def calculate_notification_stats
      # TODO: Implement when notification system is added
      { unread: 0, total: 0 }
    end
  end
end

