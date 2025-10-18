class Api::V1::UsersController < ApplicationController
  include JsonWebToken
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/v1/signup
  def create
    @user = User.new(user_params)
    if @user.save
      token = jwt_encode({ user_id: @user.id })
      render json: { token: token, user: { id: @user.id, email: @user.email, role: @user.role } }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :role)
  end
end