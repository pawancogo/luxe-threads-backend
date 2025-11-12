require 'rails_helper'

RSpec.describe 'API V1 Authentication', type: :request do
  describe 'POST /api/v1/login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
    
    context 'with valid credentials' do
      it 'returns JWT token and user data' do
        post '/api/v1/login', params: { email: user.email, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']).to have_key('token')
        expect(json_response['data']).to have_key('user')
        expect(json_response['data']['user']['id']).to eq(user.id)
        expect(json_response['data']['user']['email']).to eq(user.email)
        expect(json_response['data']['user']['role']).to eq(user.role)
      end
      
      it 'includes email_verified status' do
        post '/api/v1/login', params: { email: user.email, password: 'password123' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['user']).to have_key('email_verified')
      end
      
      it 'generates valid JWT token' do
        post '/api/v1/login', params: { email: user.email, password: 'password123' }
        
        json_response = JSON.parse(response.body)
        token = json_response['data']['token']
        
        decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
        expect(decoded['user_id']).to eq(user.id)
      end
    end
    
    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/api/v1/login', params: { email: user.email, password: 'wrongpassword' }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to be_present
      end
      
      it 'returns unauthorized for non-existent email' do
        post '/api/v1/login', params: { email: 'nonexistent@example.com', password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end
      
      it 'returns unauthorized for missing email' do
        post '/api/v1/login', params: { password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'returns unauthorized for missing password' do
        post '/api/v1/login', params: { email: user.email }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context 'with different user roles' do
      it 'works for customer role' do
        customer = create(:user, role: 'customer')
        post '/api/v1/login', params: { email: customer.email, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['user']['role']).to eq('customer')
      end
      
      it 'works for supplier role' do
        supplier = create(:user, :supplier)
        post '/api/v1/login', params: { email: supplier.email, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['user']['role']).to eq('supplier')
      end
    end
    
    context 'case sensitivity' do
      it 'handles email case insensitivity' do
        post '/api/v1/login', params: { email: user.email.upcase, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
end





