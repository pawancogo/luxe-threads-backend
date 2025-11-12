# frozen_string_literal: true

module Api::V1::Admin
  class SearchController < BaseController
    include AdminApiAuthorization
    
    # GET /api/v1/admin/search?q=...
    def search
      query = params[:q].to_s.strip
      
      if query.blank?
        render_success({
          users: [],
          orders: [],
          products: [],
          suppliers: []
        }, 'Search query is required')
        return
      end
      
      results = {
        users: search_users(query),
        orders: search_orders(query),
        products: search_products(query),
        suppliers: search_suppliers(query)
      }
      
      render_success(results, 'Search completed successfully')
    end
    
    private
    
    def search_users(query)
      User.where.not(role: 'supplier')
          .where('email LIKE ? OR first_name LIKE ? OR last_name LIKE ?', 
                 "%#{query}%", "%#{query}%", "%#{query}%")
          .limit(5)
          .map do |user|
        {
          id: user.id,
          type: 'user',
          title: user.full_name,
          subtitle: user.email,
          url: "/admin/users/#{user.id}"
        }
      end
    end
    
    def search_orders(query)
      Order.includes(:user)
          .where('order_number LIKE ? OR total_amount::text LIKE ?', 
                 "%#{query}%", "%#{query}%")
          .or(Order.joins(:user).where('users.email LIKE ?', "%#{query}%"))
          .limit(5)
          .map do |order|
        {
          id: order.id,
          type: 'order',
          title: "Order ##{order.order_number || order.id}",
          subtitle: "#{order.user&.email} - ₹#{order.total_amount}",
          url: "/admin/orders/#{order.id}"
        }
      end
    end
    
    def search_products(query)
      Product.includes(:category, :brand)
             .where('name LIKE ? OR description LIKE ?', 
                    "%#{query}%", "%#{query}%")
          .limit(5)
          .map do |product|
        {
          id: product.id,
          type: 'product',
          title: product.name,
          subtitle: "#{product.category&.name} - #{product.brand&.name}",
          url: "/admin/products/#{product.id}"
        }
      end
    end
    
    def search_suppliers(query)
      User.where(role: 'supplier')
          .joins(:supplier_profile)
          .where('users.email LIKE ? OR supplier_profiles.company_name LIKE ?',
                 "%#{query}%", "%#{query}%")
          .limit(5)
          .map do |supplier|
        {
          id: supplier.id,
          type: 'supplier',
          title: supplier.supplier_profile&.company_name || supplier.email,
          subtitle: supplier.email,
          url: "/admin/suppliers/#{supplier.id}"
        }
      end
    end
  end
end

