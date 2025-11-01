class Api::V1::AuthenticationController < ApplicationController
  include JsonWebToken
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/v1/login
  def create
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode({ user_id: @user.id })
      user_data = {
        id: @user.id,
        email: @user.email,
        role: @user.role,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email_verified: @user.email_verified?
      }
      render_success({ token: token, user: user_data }, 'Login successful')
    else
      render_unauthorized('Invalid email or password')
    end
  end
end