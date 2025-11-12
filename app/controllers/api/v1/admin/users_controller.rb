# frozen_string_literal: true

module Api::V1::Admin
  class UsersController < BaseController
    include AdminApiAuthorization
    include EagerLoading
    include StatusManageable
    
    before_action :require_permission!, only: [:index, :show], if: -> { @current_admin }
    before_action :require_permission!, only: [:create], if: -> { @current_admin }, with: 'users:create'
    before_action :require_permission!, only: [:update], if: -> { @current_admin }, with: 'users:update'
    before_action :require_permission!, only: [:destroy, :update_status], if: -> { @current_admin }, with: 'users:delete'
    before_action :set_user, only: [:show, :update, :destroy, :update_status, :orders, :activity]
    
    # GET /api/v1/admin/users
    def index
      base_scope = with_eager_loading(
        User.customers_only,
        additional_includes: user_includes
      )
      
      filtered_scope = scope_by_permission(base_scope, 'users', 'view')
      
      service = Admins::UserListingService.new(filtered_scope, params)
      service.call
      
      if service.success?
        render_success(
          AdminUserSerializer.collection(service.users),
          'Users retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve users')
      end
    end
    
    # GET /api/v1/admin/users/:id
    def show
      render_success(
        AdminUserSerializer.new(@user).as_json,
        'User retrieved successfully'
      )
    end
    
    # PATCH /api/v1/admin/users/:id
    def update
      user_params_data = params[:user] || {}
      
      service = Users::UpdateService.new(@user, user_params_data.permit(:first_name, :last_name, :phone_number, :email))
      service.call
      
      if service.success?
        log_admin_activity('update', 'User', @user.id, @user.previous_changes)
        render_success(
          AdminUserSerializer.new(@user.reload).as_json,
          'User updated successfully'
        )
      else
        render_validation_errors(service.errors, 'User update failed')
      end
    end
    
    # DELETE /api/v1/admin/users/:id
    def destroy
      user_id = @user.id
      
      service = Users::DeletionService.new(@user)
      service.call
      
      if service.success?
        log_admin_activity('destroy', 'User', user_id)
        render_success({ id: user_id }, 'User deleted successfully')
      else
        render_validation_errors(service.errors, 'User deletion failed')
      end
    end
    
    # Uses StatusManageable concern
    def update_status
      super
    end
    
    # GET /api/v1/admin/users/:id/orders
    def orders
      @orders = with_eager_loading(
        @user.orders,
        additional_includes: order_includes
      )
      .with_status(params[:status])
      .order(created_at: :desc)
      
      render_success(
        AdminOrderSerializer.collection(@orders),
        'User orders retrieved successfully'
      )
    end
    
    # GET /api/v1/admin/users/:id/activity
    def activity
      service = UserActivityService.new(@user)
      service.call
      
      if service.success?
        render_success(service.activities, 'User activity retrieved successfully')
      else
        render_error(service.errors.first || 'Failed to retrieve user activity', :unprocessable_entity)
      end
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
    
    # StatusManageable implementation
    def get_status_resource
      @user
    end

    def activate_resource(resource)
      service = Users::ActivationService.new(resource)
      service.call
      service.success?
    end

    def deactivate_resource(resource)
      service = Users::DeactivationService.new(resource)
      service.call
      service.success?
    end

    def prevent_self_modification?(resource)
      false
    end

    def format_resource_data(resource)
      AdminUserSerializer.new(resource).as_json
    end

    def handle_status_success(resource, action)
      changes = action == 'activate' ? 
        { deleted_at: [resource.deleted_at_before_last_save, nil] } : 
        { deleted_at: [resource.deleted_at_before_last_save, Time.current] }
      log_admin_activity('update', 'User', resource.id, changes)
      super
    end
  end
end

