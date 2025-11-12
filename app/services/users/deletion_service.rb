# frozen_string_literal: true

# Service for handling user deletion with proper cleanup
# Extracted from User model to follow Single Responsibility Principle
module Users
  class DeletionService < BaseService
    def initialize(user)
      super()
      @user = user
    end

    def call
      with_transaction do
        cleanup_orders
        cleanup_addresses
        cleanup_reviews
        cleanup_cart_and_wishlist
        cleanup_return_requests
        cleanup_supplier_profile
        set_result(true)
      end
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def cleanup_orders
      return unless @user.orders.exists?

      # Nullify order foreign keys first to prevent constraint violations
      @user.orders.update_all(shipping_address_id: nil, billing_address_id: nil)
      @user.orders.delete_all
    end

    def cleanup_addresses
      @user.addresses.delete_all
    end

    def cleanup_reviews
      @user.reviews.delete_all
    end

    def cleanup_cart_and_wishlist
      @user.cart&.cart_items&.delete_all
      @user.cart&.delete
      @user.wishlist&.wishlist_items&.delete_all
      @user.wishlist&.delete
    end

    def cleanup_return_requests
      return unless model_exists?('ReturnRequest')

      ReturnRequest.where(user_id: @user.id).find_each(&:destroy)
    rescue StandardError => e
      Rails.logger.error "Error deleting return requests for user #{@user.id}: #{e.message}"
    end

    def cleanup_supplier_profile
      return unless @user.supplier_profile.present?

      @user.supplier_profile.products&.delete_all
      @user.supplier_profile.delete
    end

    def model_exists?(model_name)
      model_name.constantize.table_exists?
    rescue NameError, NoMethodError
      false
    end
  end
end

