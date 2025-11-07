# frozen_string_literal: true

# Service for permanently deleting User records in RailsAdmin
# Handles cleanup of all dependencies before calling really_destroy!
class UserPermanentDeletionService
  def self.delete(user)
    new(user).delete
  end

  def initialize(user)
    @user = user
  end

  def delete
    ActiveRecord::Base.transaction do
      # Temporarily disable foreign key constraints for SQLite
      disable_foreign_keys
      
      cleanup_dependencies
      @user.really_destroy!
      
      true
    end
  rescue StandardError => e
    Rails.logger.error "UserPermanentDeletionService: Failed to delete User #{@user.id}: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  ensure
    enable_foreign_keys
  end

  private

  def cleanup_dependencies
    # Delete in correct order to respect foreign key constraints
    
    # 1. Delete return media first (references return items)
    if model_exists?('ReturnMedia') && model_exists?('ReturnItem') && model_exists?('ReturnRequest')
      return_request_ids = ReturnRequest.where(user_id: @user.id).pluck(:id)
      return_item_ids = ReturnItem.where(return_request_id: return_request_ids).pluck(:id) if return_request_ids.any?
      ReturnMedia.where(return_item_id: return_item_ids).delete_all if return_item_ids&.any?
    end
    
    # 2. Delete return items (they reference return requests and order items)
    if model_exists?('ReturnRequest') && model_exists?('ReturnItem')
      return_request_ids = ReturnRequest.where(user_id: @user.id).pluck(:id)
      ReturnItem.where(return_request_id: return_request_ids).delete_all if return_request_ids.any?
    end
    
    # 3. Delete return requests (they reference orders and users)
    if model_exists?('ReturnRequest')
      ReturnRequest.where(user_id: @user.id).delete_all
    end
    
    # 4. Delete order items before orders (order_items has foreign key to orders)
    if @user.orders.exists?
      order_ids = @user.orders.pluck(:id)
      OrderItem.where(order_id: order_ids).delete_all if defined?(OrderItem) && OrderItem.table_exists?
      
      # 5. Delete orders (foreign key constraints temporarily disabled)
      @user.orders.delete_all
    end
    
    # 6. Delete addresses (after orders are gone)
    @user.addresses.delete_all
    
    # 7. Delete reviews (they reference products and users)
    @user.reviews.delete_all
    
    # 8. Delete cart items and cart
    if @user.cart.present?
      CartItem.where(cart_id: @user.cart.id).delete_all if defined?(CartItem) && CartItem.table_exists?
      @user.cart.delete
    end
    
    # 9. Delete wishlist items and wishlist
    if @user.wishlist.present?
      WishlistItem.where(wishlist_id: @user.wishlist.id).delete_all if defined?(WishlistItem) && WishlistItem.table_exists?
      @user.wishlist.delete
    end
    
    # 10. Delete supplier profile and products
    if @user.supplier_profile.present?
      # Delete products that reference supplier_profile
      Product.where(supplier_profile_id: @user.supplier_profile.id).delete_all if defined?(Product) && Product.table_exists?
      @user.supplier_profile.delete
    end
  end
  
  def disable_foreign_keys
    # SQLite: Temporarily disable foreign key checks
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF')
    end
  end
  
  def enable_foreign_keys
    # SQLite: Re-enable foreign key checks
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON')
    end
  end

  def model_exists?(model_name)
    model_name.constantize.table_exists?
  rescue NameError, NoMethodError
    false
  end
end

