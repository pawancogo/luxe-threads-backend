require 'rails_helper'

RSpec.describe Api::V1::Admin::AuthenticationController, type: :controller do
  let(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'authenticates admin successfully' do
        post :create, params: { email: admin.email, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']).to have_key('token')
        expect(json_response['data']).to have_key('admin')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post :create, params: { email: admin.email, password: 'wrongpassword' }
        
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for non-existent admin' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

