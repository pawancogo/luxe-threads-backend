require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    it 'authenticates user with valid credentials' do
      post :create, params: { email: user.email, password: 'password123' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to have_key('token')
      expect(json_response['data']).to have_key('user')
    end

    it 'returns error for invalid credentials' do
      post :create, params: { email: user.email, password: 'wrong_password' }
      
      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to include('Invalid')
    end

    it 'returns error for non-existent user' do
      post :create, params: { email: 'nonexistent@example.com', password: 'password123' }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
