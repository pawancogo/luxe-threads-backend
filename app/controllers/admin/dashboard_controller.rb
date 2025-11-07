class Admin::DashboardController < Admin::BaseController
    def index
      # Dashboard statistics
      @stats = {
        total_users:            User.where.not(role: 'supplier').count,
        total_suppliers:        User.where(role: 'supplier').count,
        total_products:         Product.count,
        pending_products:       Product.where(status: 'pending').count,
        active_products:        Product.where(status: 'active').count,
        total_orders:           Order.count,
        pending_orders:         Order.where(status: 'pending').count,
        shipped_orders:         Order.where(status: 'shipped').count,
        featured_products:      Product.where(is_featured: true).count,
        low_stock_variants:     ProductVariant.where(is_low_stock: true).count,
        out_of_stock_variants:  ProductVariant.where(out_of_stock: true).count,
        categories_count:       Category.count,
        recent_orders:           Order.includes(:user)
                                    .order(created_at: :desc)
                                    .limit(10),
        recent_products:         Product.includes(:supplier_profile, :category, :brand)
                                    .order(created_at: :desc)
                                    .limit(10)
      }
      
      # All orders for the orders table
      @orders = Order.includes(:user)
                     .order(created_at: :desc)
                     .page(params[:page])
    end
  end


