# frozen_string_literal: true

# Refactored UsersController using new architecture
# Uses Service objects instead of callbacks
class Api::V1::UsersController < ApplicationController
  include EagerLoading
  
  skip_before_action :authenticate_request, only: [:create]
  before_action :set_user, only: [:show, :update, :destroy]

  # POST /api/v1/users (signup)
  def create
    # Set password_confirmation to password if not provided (for signup, password confirmation can be implicit)
    params_hash = user_params.to_h
    params_hash[:password_confirmation] ||= params_hash[:password] if params_hash[:password].present?
    
    begin
      service = Users::CreationService.new(params_hash)
      result = service.call
      
      if service.success?
        # Generate JWT token for the new user
        token = jwt_encode({ user_id: service.user.id })
        
        # Set httpOnly cookie for token
        cookies.signed[:auth_token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 7.days.from_now
        }
        
        # Return user data (token is in cookie, not in response)
        render_created(
          { user: UserSerializer.new(service.user).as_json },
          'User created successfully'
        )
      else
        # Service already handled validation errors
        # Check if there's a server error that should include trace (dev/test)
        if service.last_error.present?
          render_server_error('User creation failed', service.last_error)
        else
          render_validation_errors(service.errors.uniq, 'User creation failed')
        end
      end
    rescue ActiveRecord::RecordNotUnique => e
      # Database constraint error - handle it specifically
      handle_constraint_error(e)
    rescue StandardError => e
      # Catch constraint errors that might not be caught by validation
      message = e.message.to_s.downcase
      if message.include?('unique') || message.include?('constraint')
        handle_constraint_error(e)
      else
        Rails.logger.error "Error creating user: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render_server_error('An error occurred while creating your account', e)
      end
    end
  end

  # GET /api/v1/users/me
  def me
    user = with_eager_loading(User.where(id: current_user.id), additional_includes: user_includes).first
    render_success(
      UserProfileSerializer.new(user).as_json,
      'User profile retrieved successfully'
    )
  end

  # GET /api/v1/users/:id
  def show
    render_success(
      UserSerializer.new(@user).as_json,
      'User retrieved successfully'
    )
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    # Handle password change separately if current_password is provided
    if params[:user][:current_password].present? && params[:user][:password].present?
      service = Users::PasswordUpdateService.new(
        @user,
        params[:user][:current_password],
        params[:user][:password],
        params[:user][:password_confirmation]
      )
      service.call
      
      if service.success?
        render_success(
          UserSerializer.new(@user.reload).as_json,
          'Password changed successfully'
        )
      else
        render_validation_errors(service.errors, 'Password change failed')
      end
    else
      # Regular update (without password change)
      service = Users::GeneralUpdateService.new(@user, user_params)
      service.call
      
      if service.success?
        render_success(
          UserSerializer.new(@user.reload).as_json,
          'User updated successfully'
        )
      else
        render_validation_errors(service.errors, 'User update failed')
      end
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    begin
      service = Users::DeletionService.new(@user)
      service.call
      
      if service.success?
        render_no_content('User deleted successfully')
      else
        render_validation_errors(service.errors, 'Failed to delete user')
      end
    rescue ActiveRecord::InvalidForeignKey => e
      handle_constraint_error(e)
    rescue ActiveRecord::StatementInvalid => e
      message = e.message.to_s.downcase
      if message.include?('foreign key constraint') || message.include?('constraint')
        handle_constraint_error(e)
      else
        Rails.logger.error "Error deleting user #{@user.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render_server_error('An error occurred while deleting the user', e)
      end
    rescue => e
      Rails.logger.error "Error deleting user #{@user.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_server_error('An error occurred while deleting the user', e)
    end
  end

  # POST /api/v1/users/bulk_delete
  def bulk_delete
    service = BulkDeletionService.new(User)
    result = service.delete(params[:user_ids] || [])
    
    respond_to_bulk_deletion_result(service, result)
  rescue ArgumentError => e
    render_bad_request(e.message, ['user_ids: must be a non-empty array'])
  end

  private

  def respond_to_bulk_deletion_result(service, result)
    if service.success?
      render_success(
        { deleted_count: result[:deleted_count], message: "Successfully deleted #{result[:deleted_count]} user(s)" },
        "Successfully deleted #{result[:deleted_count]} user(s)"
      )
    elsif service.partial_success?
      render_error(
        "Partially successful: deleted #{result[:deleted_count]} user(s), failed to delete #{result[:failed_count]} user(s)",
        result[:errors],
        :partial_content
      )
    else
      render_error(
        "Failed to delete any users",
        result[:errors],
        :unprocessable_entity
      )
    end
  end

  private

  def set_user
    @user = with_eager_loading(User.all, additional_includes: user_includes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('User not found')
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :password,
      :password_confirmation,
      :current_password,
      :role
    )
  end

  def user_includes
    [:addresses, :orders, :cart, :wishlist]
  end
end
