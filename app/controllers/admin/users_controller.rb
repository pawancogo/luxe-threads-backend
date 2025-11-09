# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
    include StatusManageable
    
    before_action :require_user_admin_role!, only: [:index, :show, :update, :destroy, :update_status]
    before_action :enable_date_filter, only: [:index]
    before_action :set_user, only: [:show, :edit, :update, :destroy, :update_status, :orders, :activity]

    def index
      search_options = { date_range_column: :created_at }
      search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
      @users = User.where.not(role: 'supplier')._search(params, **search_options).order(created_at: :desc)
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

    # Uses StatusManageable concern
    def update_status
      super
    end

    def orders
      @orders = @user.orders.order(created_at: :desc).page(params[:page])
    end

    def activity
      # Activity log for user
      @activities = []
    end

    def bulk_action
      user_ids = params[:user_ids]&.split(',')&.reject(&:blank?) || []
      action = params[:bulk_action]
      
      return redirect_to admin_users_path(request.query_parameters), alert: 'Please select at least one user.' if user_ids.empty?
      
      users = User.where(id: user_ids)
      count = 0
      
      case action
      when 'activate'
        users.update_all(is_active: true, deleted_at: nil)
        count = users.count
        notice = "#{count} user(s) activated successfully."
      when 'deactivate'
        users.find_each do |user|
          user.update(is_active: false, deleted_at: Time.current)
          # Send verification email to each user
          unless user.email_verifications.pending.active.exists?
            EmailVerificationService.new(user).send_verification_email
          end
        end
        count = users.count
        notice = "#{count} user(s) deactivated successfully. Verification emails have been sent to reactivate their accounts."
      when 'delete'
        users.destroy_all
        count = users.count
        notice = "#{count} user(s) deleted successfully."
      else
        return redirect_to admin_users_path(request.query_parameters), alert: 'Invalid action.'
      end
      
      redirect_to admin_users_path(request.query_parameters), notice: notice
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

    # StatusManageable implementation
    def get_status_resource
      @user
    end

    def activate_resource(resource)
      resource.update(is_active: true, deleted_at: nil)
    end

    def deactivate_resource(resource)
      resource.update(is_active: false, deleted_at: Time.current)
      
      # Send verification email to user so they can reactivate their account
      unless resource.email_verifications.pending.active.exists?
        EmailVerificationService.new(resource).send_verification_email
      end
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

