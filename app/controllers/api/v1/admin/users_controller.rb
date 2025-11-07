# frozen_string_literal: true

module Api::V1::Admin
  class UsersController < BaseController
    include AdminApiAuthorization
    include EagerLoading
    
    before_action :require_permission!, only: [:index, :show], if: -> { @current_admin }
    before_action :require_permission!, only: [:create], if: -> { @current_admin }, with: 'users:create'
    before_action :require_permission!, only: [:update], if: -> { @current_admin }, with: 'users:update'
    before_action :require_permission!, only: [:destroy, :activate, :deactivate], if: -> { @current_admin }, with: 'users:delete'
    before_action :set_user, only: [:show, :update, :destroy, :activate, :deactivate, :orders, :activity]
    
    # GET /api/v1/admin/users
    def index
      # Scope by permission (RBAC-aware)
      base_scope = with_eager_loading(
        User.where.not(role: 'supplier'),
        additional_includes: user_includes
      )
      
      @users = scope_by_permission(base_scope, 'users', 'view')
               .order(created_at: :desc)
      
      # Filters
      @users = @users.where('email LIKE ?', "%#{params[:email]}%") if params[:email].present?
      @users = @users.where('first_name LIKE ? OR last_name LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where.not(deleted_at: nil) if params[:active] == 'false' # Inactive users
      @users = @users.where(deleted_at: nil) if params[:active] == 'true' # Active users
      
      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      @users = @users.page(page).per(per_page)
      
      render_success(format_users_data(@users), 'Users retrieved successfully')
    end
    
    # GET /api/v1/admin/users/:id
    def show
      render_success(format_user_detail_data(@user), 'User retrieved successfully')
    end
    
    # PATCH /api/v1/admin/users/:id
    def update
      user_params_data = params[:user] || {}
      
      if @user.update(user_params_data.permit(:first_name, :last_name, :phone_number, :email))
        log_admin_activity('update', 'User', @user.id, @user.previous_changes)
        render_success(format_user_detail_data(@user), 'User updated successfully')
      else
        render_validation_errors(@user.errors.full_messages, 'User update failed')
      end
    end
    
    # DELETE /api/v1/admin/users/:id
    def destroy
      user_id = @user.id
      if @user.destroy
        log_admin_activity('destroy', 'User', user_id)
        render_success({ id: user_id }, 'User deleted successfully')
      else
        render_validation_errors(@user.errors.full_messages, 'User deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/users/:id/activate
    def activate
      if @user.update(deleted_at: nil)
        log_admin_activity('update', 'User', @user.id, { deleted_at: [@user.deleted_at_before_last_save, nil] })
        render_success(format_user_detail_data(@user), 'User activated successfully')
      else
        render_validation_errors(@user.errors.full_messages, 'User activation failed')
      end
    end
    
    # PATCH /api/v1/admin/users/:id/deactivate
    def deactivate
      if @user.update(deleted_at: Time.current)
        log_admin_activity('update', 'User', @user.id, { deleted_at: [@user.deleted_at_before_last_save, Time.current] })
        render_success(format_user_detail_data(@user), 'User deactivated successfully')
      else
        render_validation_errors(@user.errors.full_messages, 'User deactivation failed')
      end
    end
    
    # GET /api/v1/admin/users/:id/orders
    def orders
      @orders = with_eager_loading(
        @user.orders,
        additional_includes: order_includes
      ).order(created_at: :desc)
      
      # Filter by status if provided
      @orders = @orders.where(status: params[:status]) if params[:status].present?
      
      render_success(format_orders_data(@orders), 'User orders retrieved successfully')
    end
    
    # GET /api/v1/admin/users/:id/activity
    def activity
      # Get user's recent activity (orders, reviews, etc.)
      activities = []
      
      # Recent orders
      recent_orders = @user.orders.order(created_at: :desc).limit(10)
      activities.concat(recent_orders.map { |o| { type: 'order', action: 'created', resource_id: o.id, timestamp: o.created_at, data: { order_number: o.order_number, status: o.status } } })
      
      # Recent reviews
      recent_reviews = @user.reviews.order(created_at: :desc).limit(10) if @user.respond_to?(:reviews)
      activities.concat(recent_reviews.map { |r| { type: 'review', action: 'created', resource_id: r.id, timestamp: r.created_at, data: { product_id: r.product_id, rating: r.rating } } }) if recent_reviews
      
      # Sort by timestamp
      activities.sort_by! { |a| a[:timestamp] }.reverse!
      
      render_success(activities, 'User activity retrieved successfully')
    end
    
    private
    
    def require_user_admin_role!
      require_role!(['super_admin', 'user_admin'])
    end
    
    def set_user
      @user = with_eager_loading(User.all, additional_includes: user_includes).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('User not found')
    end
    
    def format_users_data(users)
      users.map { |user| format_user_data(user) }
    end
    
    def format_user_data(user)
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        full_name: user.full_name,
        phone_number: user.phone_number,
        role: user.role,
        is_active: user.deleted_at.nil?,
        created_at: user.created_at,
        orders_count: user.orders_count || 0
      }
    end
    
    def format_user_detail_data(user)
      format_user_data(user).merge(
        addresses: user.addresses.map { |a| { id: a.id, street: a.street, city: a.city, state: a.state, zip_code: a.zip_code, is_default: a.is_default } },
        deleted_at: user.deleted_at,
        updated_at: user.updated_at
      )
    end
    
    def format_orders_data(orders)
      orders.map do |order|
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_amount: order.total_amount.to_f,
          created_at: order.created_at,
          items_count: order.order_items.count
        }
      end
    end
  end
end

