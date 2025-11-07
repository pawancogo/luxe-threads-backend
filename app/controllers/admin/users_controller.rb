# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
    before_action :require_user_admin_role!, only: [:index, :show, :update, :destroy, :activate, :deactivate]
    before_action :enable_date_filter, only: [:index]
    before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :orders, :activity]

    def index
      @users = User.where.not(role: 'supplier')._search(params, date_range_column: :created_at).order(created_at: :desc)
      @filters.merge!(@users.filter_with_aggs)
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'User updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user_id = @user.id
      @user.destroy
      redirect_to admin_users_path, notice: 'User deleted successfully.'
    end

    def activate
      @user.update(is_active: true, deleted_at: nil)
      redirect_to admin_user_path(@user), notice: 'User activated successfully.'
    end

    def deactivate
      @user.update(is_active: false, deleted_at: Time.current)
      redirect_to admin_user_path(@user), notice: 'User deactivated successfully.'
    end

    def orders
      @orders = @user.orders.order(created_at: :desc).page(params[:page])
    end

    def activity
      # Activity log for user
      @activities = []
    end

    def bulk_action
      user_ids = params[:user_ids]&.split(',') || []
      action = params[:bulk_action]
      
      return redirect_to admin_users_path, alert: 'Please select at least one user.' if user_ids.empty?
      
      users = User.where(id: user_ids)
      count = 0
      
      case action
      when 'activate'
        users.update_all(is_active: true, deleted_at: nil)
        count = users.count
        notice = "#{count} user(s) activated successfully."
      when 'deactivate'
        users.update_all(is_active: false, deleted_at: Time.current)
        count = users.count
        notice = "#{count} user(s) deactivated successfully."
      when 'delete'
        users.destroy_all
        count = users.count
        notice = "#{count} user(s) deleted successfully."
      else
        return redirect_to admin_users_path, alert: 'Invalid action.'
      end
      
      redirect_to admin_users_path, notice: notice
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :is_active)
    end

    def require_user_admin_role!
      unless current_admin&.super_admin? || current_admin&.user_admin?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
    end
  end

