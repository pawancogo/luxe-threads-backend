require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::UsersController.superclass).to eq(ApplicationController)
    end
  end

  describe 'concerns' do
    it 'includes JsonWebToken' do
      expect(Api::V1::UsersController.ancestors).to include(JsonWebToken)
    end
  end

  describe 'before_actions' do
    it 'has authenticate_request before_action' do
      expect(Api::V1::UsersController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          phone_number: '1234567890',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'customer'
        }
      }
    end

    it 'creates user with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('token')
      expect(JSON.parse(response.body)).to have_key('user')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(user: { email: 'invalid' })
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'returns error with duplicate email' do
      create(:user, email: 'john@example.com')
      post :create, params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end
end