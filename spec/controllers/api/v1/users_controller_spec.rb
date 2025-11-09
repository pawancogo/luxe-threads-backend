require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #show' do
    it 'returns current user details' do
      get :show
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(user.id)
    end
  end

  describe 'PATCH #update' do
    it 'updates user profile' do
      patch :update, params: { user: { first_name: 'Updated Name' } }
      
      expect(response).to have_http_status(:success)
      expect(user.reload.first_name).to eq('Updated Name')
    end

    it 'returns validation errors for invalid data' do
      patch :update, params: { user: { email: 'invalid-email' } }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
