module Admin
  class DashboardController < BaseController
    def index
      # Dashboard statistics
      @stats = {
        total_users: User.count,
        total_suppliers: Supplier.count,
        total_products: Product.count,
        total_orders: Order.count,
        pending_products: Product.where(status: 'pending').count,
        recent_orders: Order.order(created_at: :desc).limit(5),
        recent_users: User.order(created_at: :desc).limit(5),
        recent_suppliers: Supplier.order(created_at: :desc).limit(5)
      }
    end
  end
end


