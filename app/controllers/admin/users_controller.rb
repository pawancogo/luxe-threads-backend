# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
    include StatusManageable
    include EagerLoading
    
    before_action :require_user_admin_role!, only: [:index, :show, :update, :destroy, :update_status]
    before_action :enable_date_filter, only: [:index]
    before_action :set_user, only: [:show, :edit, :update, :destroy, :update_status, :orders, :activity]

    def index
      search_options = { date_range_column: :created_at }
      search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
      
      service = Admins::HtmlUserListingService.new(User.customers_only, params, search_options)
      service.call
      
      if service.success?
        @users = service.users
        @filters.merge!(service.filters)
        @user_presenters = @users.map { |user| UserPresenter.new(user) }
      else
        @users = User.none
        @filters = {}
        @user_presenters = []
        flash[:alert] = service.errors.join(', ')
      end
    end

    def show
      @user_presenter = UserPresenter.new(@user)
    end

    def edit
      @user_presenter = UserPresenter.new(@user)
    end

    def update
      service = Users::UpdateService.new(@user, user_params)
      service.call
      
      if service.success?
        redirect_to admin_user_path(@user), notice: 'User updated successfully.'
      else
        @user_presenter = UserPresenter.new(@user)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      service = Users::DeletionService.new(@user)
      service.call
      
      if service.success?
        redirect_to admin_users_path, notice: 'User deleted successfully.'
      else
        redirect_to admin_users_path, alert: service.errors.first || 'Failed to delete user'
      end
    end

    # Uses StatusManageable concern
    def update_status
      super
    end

    def orders
      service = UserOrderListingService.new(@user.orders, params)
      service.call
      
      if service.success?
        @orders = service.orders
      else
        @orders = Order.none
      end
    end

    def activity
      # Activity log for user
      @activities = []
    end

    def bulk_action
      service = Users::BulkActionService.new(
        params[:user_ids]&.split(','),
        params[:bulk_action],
        admin: current_admin
      )
      service.call
      
      if service.success?
        count = service.result.count
        action = params[:bulk_action]
        notice = case action
      when 'activate'
          "#{count} user(s) activated successfully."
      when 'deactivate'
          "#{count} user(s) deactivated successfully. Verification emails have been sent to reactivate their accounts."
      when 'delete'
          "#{count} user(s) deleted successfully."
        end
        redirect_to admin_users_path(request.query_parameters), notice: notice
      else
        redirect_to admin_users_path(request.query_parameters), alert: service.errors.join(', ')
      end
    end

    private

    def set_user
      @user = with_eager_loading(User.all, additional_includes: user_includes).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: 'User not found.'
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :is_active)
    end

    def require_user_admin_role!
      unless current_admin&.super_admin? || current_admin&.user_admin?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
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
      false # Users can modify their own status if needed
    end

    def status_success_path(resource)
      admin_user_path(resource)
    end

    def status_error_path
      admin_user_path(@user)
    end
    
    def handle_status_success(resource, action)
      if action == 'deactivate'
        # Custom message for deactivation
        flash[:notice] = "#{resource.full_name} has been deactivated. A verification email has been sent to #{resource.email}. They will need to verify their email to reactivate their account."
      end
      super
    end
  end

