class Api::V1::UsersController < ApplicationController
  include JsonWebToken
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/v1/signup
  def create
    @user = User.new(user_params)
    if @user.save
      token = jwt_encode({ user_id: @user.id })
      user_data = {
        id: @user.id,
        email: @user.email,
        role: @user.role,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email_verified: @user.email_verified?
      }
      render_created({ token: token, user: user_data }, 'User created successfully. Please verify your email.')
    else
      render_validation_errors(@user.errors.full_messages, 'User creation failed')
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password, :role)
  end
end