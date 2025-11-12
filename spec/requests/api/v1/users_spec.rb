require 'rails_helper'

RSpec.describe 'API V1 Users', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }
  
  describe 'POST /api/v1/signup' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            first_name: 'John',
            last_name: 'Doe',
            phone_number: '1234567890',
            role: 'customer'
          }
        }
      end
      
      it 'creates a new user' do
        expect {
          post '/api/v1/signup', params: valid_params
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']).to have_key('token')
        expect(json_response['data']).to have_key('user')
        expect(json_response['data']['user']['email']).to eq('newuser@example.com')
      end
      
      it 'creates associated cart and wishlist' do
        post '/api/v1/signup', params: valid_params
        
        new_user = User.find_by(email: 'newuser@example.com')
        expect(new_user.cart).to be_present
        expect(new_user.wishlist).to be_present
      end
      
      it 'creates email verification record' do
        post '/api/v1/signup', params: valid_params
        
        new_user = User.find_by(email: 'newuser@example.com')
        expect(new_user.email_verifications).to be_present
      end
      
      it 'returns JWT token for immediate login' do
        post '/api/v1/signup', params: valid_params
        
        json_response = JSON.parse(response.body)
        token = json_response['data']['token']
        expect(token).to be_present
        
        decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
        new_user = User.find_by(email: 'newuser@example.com')
        expect(decoded['user_id']).to eq(new_user.id)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors for duplicate email' do
        create(:user, email: 'existing@example.com')
        
        post '/api/v1/signup', params: {
          user: {
            email: 'existing@example.com',
            password: 'password123',
            first_name: 'John',
            last_name: 'Doe'
          }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to be_present
      end
      
      it 'returns validation errors for missing email' do
        post '/api/v1/signup', params: {
          user: {
            password: 'password123',
            first_name: 'John',
            last_name: 'Doe'
          }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for password mismatch' do
        post '/api/v1/signup', params: {
          user: {
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'different',
            first_name: 'John',
            last_name: 'Doe'
          }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for short password' do
        post '/api/v1/signup', params: {
          user: {
            email: 'test@example.com',
            password: 'short',
            first_name: 'John',
            last_name: 'Doe'
          }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'with supplier role' do
      it 'creates supplier user successfully' do
        post '/api/v1/signup', params: {
          user: {
            email: 'supplier@example.com',
            password: 'password123',
            first_name: 'Supplier',
            last_name: 'User',
            role: 'supplier'
          }
        }
        
        expect(response).to have_http_status(:created)
        new_user = User.find_by(email: 'supplier@example.com')
        expect(new_user.role).to eq('supplier')
      end
    end
  end
  
  describe 'GET /api/v1/users/:id' do
    context 'with authentication' do
      it 'returns user details' do
        get "/api/v1/users/#{user.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['id']).to eq(user.id)
        expect(json_response['data']['email']).to eq(user.email)
      end
      
      it 'includes all user fields' do
        get "/api/v1/users/#{user.id}", headers: auth_headers
        
        json_response = JSON.parse(response.body)
        data = json_response['data']
        expect(data).to have_key('first_name')
        expect(data).to have_key('last_name')
        expect(data).to have_key('full_name')
        expect(data).to have_key('email')
        expect(data).to have_key('phone_number')
        expect(data).to have_key('role')
        expect(data).to have_key('email_verified')
      end
    end
    
    context 'without authentication' do
      it 'returns unauthorized' do
        get "/api/v1/users/#{user.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context 'with non-existent user' do
      it 'returns not found' do
        get '/api/v1/users/99999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'PATCH /api/v1/users/:id' do
    context 'with valid parameters' do
      it 'updates user successfully' do
        patch "/api/v1/users/#{user.id}", 
              params: { user: { first_name: 'Updated', last_name: 'Name' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.first_name).to eq('Updated')
        expect(user.last_name).to eq('Name')
      end
      
      it 'updates phone number' do
        patch "/api/v1/users/#{user.id}", 
              params: { user: { phone_number: '9876543210' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.phone_number).to eq('9876543210')
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors for invalid email format' do
        patch "/api/v1/users/#{user.id}", 
              params: { user: { email: 'invalid-email' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for duplicate email' do
        other_user = create(:user, email: 'other@example.com')
        
        patch "/api/v1/users/#{user.id}", 
              params: { user: { email: 'other@example.com' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'without authentication' do
      it 'returns unauthorized' do
        patch "/api/v1/users/#{user.id}", params: { user: { first_name: 'Updated' } }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'DELETE /api/v1/users/:id' do
    context 'with authentication' do
      it 'deletes user successfully' do
        user_to_delete = create(:user)
        auth_headers_delete = { 'Authorization' => "Bearer #{jwt_encode({ user_id: user_to_delete.id })}" }
        
        expect {
          delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers_delete
        }.to change(User, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
      
      it 'deletes associated resources' do
        user_to_delete = create(:user)
        create(:cart, user: user_to_delete)
        create(:wishlist, user: user_to_delete)
        auth_headers_delete = { 'Authorization' => "Bearer #{jwt_encode({ user_id: user_to_delete.id })}" }
        
        delete "/api/v1/users/#{user_to_delete.id}", headers: auth_headers_delete
        
        expect(Cart.where(user_id: user_to_delete.id)).to be_empty
        expect(Wishlist.where(user_id: user_to_delete.id)).to be_empty
      end
    end
    
    context 'without authentication' do
      it 'returns unauthorized' do
        delete "/api/v1/users/#{user.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'POST /api/v1/users/bulk_delete' do
    context 'with valid user IDs' do
      it 'deletes multiple users' do
        users = create_list(:user, 3)
        user_ids = users.map(&:id)
        
        expect {
          post '/api/v1/users/bulk_delete', 
               params: { user_ids: user_ids },
               headers: auth_headers
        }.to change(User, :count).by(-3)
        
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns count of deleted users' do
        users = create_list(:user, 2)
        user_ids = users.map(&:id)
        
        post '/api/v1/users/bulk_delete', 
             params: { user_ids: user_ids },
             headers: auth_headers
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['deleted_count']).to eq(2)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns error for empty array' do
        post '/api/v1/users/bulk_delete', 
             params: { user_ids: [] },
             headers: auth_headers
        
        expect(response).to have_http_status(:bad_request)
      end
      
      it 'returns error for non-existent user IDs' do
        post '/api/v1/users/bulk_delete', 
             params: { user_ids: [99999, 99998] },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





