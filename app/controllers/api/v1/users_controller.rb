# frozen_string_literal: true

# Refactored UsersController using new architecture
# Uses Service objects instead of callbacks
class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # POST /api/v1/users (signup)
  def create
    service = UserCreationService.new(user_params)
    result = service.call
    
    if service.success?
      render_created(format_user_data(service.user), 'User created successfully')
    else
      render_validation_errors(service.errors, 'User creation failed')
    end
  end

  # GET /api/v1/users/:id
  def show
    render_success(format_user_data(@user), 'User retrieved successfully')
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    if @user.update(user_params)
      render_success(format_user_data(@user), 'User updated successfully')
    else
      render_validation_errors(@user.errors.full_messages, 'User update failed')
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    @user.destroy
    render_no_content('User deleted successfully')
  end

  private

  def set_user
    @user = User.find(params[:id])
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
      :role
    )
  end

  def format_user_data(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      email: user.email,
      phone_number: user.phone_number,
      role: user.role,
      email_verified: user.email_verified?,
      created_at: user.created_at.iso8601,
      updated_at: user.updated_at.iso8601
    }
  end
end
