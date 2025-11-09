require 'rails_helper'

RSpec.describe 'API V1 Password Reset', type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  
  describe 'POST /api/v1/password/forgot' do
    context 'with valid email' do
      it 'sends password reset email' do
        expect {
          post '/api/v1/password/forgot', params: { email: user.email }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
      
      it 'generates temporary password' do
        post '/api/v1/password/forgot', params: { email: user.email }
        
        user.reload
        expect(user.temp_password).to be_present
        expect(user.temp_password_expires_at).to be_present
      end
      
      it 'returns success message even if email does not exist (security)' do
        post '/api/v1/password/forgot', params: { email: 'nonexistent@example.com' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end
    
    context 'with invalid parameters' do
      it 'returns error for blank email' do
        post '/api/v1/password/forgot', params: { email: '' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end
      
      it 'returns error for missing email' do
        post '/api/v1/password/forgot'
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'email case insensitivity' do
      it 'handles uppercase email' do
        post '/api/v1/password/forgot', params: { email: user.email.upcase }
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
  
  describe 'POST /api/v1/password/reset' do
    before do
      user.generate_temp_password!
    end
    
    context 'with valid parameters' do
      it 'resets password successfully' do
        temp_password = user.temp_password
        
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: temp_password,
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        
        # Verify new password works
        user.reload
        expect(user.authenticate('newpassword123')).to be_truthy
      end
      
      it 'clears temporary password after reset' do
        temp_password = user.temp_password
        
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: temp_password,
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        
        user.reload
        expect(user.temp_password).to be_nil
        expect(user.temp_password_expires_at).to be_nil
      end
    end
    
    context 'with invalid parameters' do
      it 'returns error for wrong temporary password' do
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: 'wrongtemp',
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'returns error for expired temporary password' do
        user.update(temp_password_expires_at: 1.hour.ago)
        temp_password = user.temp_password
        
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: temp_password,
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for password mismatch' do
        temp_password = user.temp_password
        
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: temp_password,
          new_password: 'newpassword123',
          password_confirmation: 'differentpassword'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for blank email' do
        post '/api/v1/password/reset', params: {
          email: '',
          temp_password: user.temp_password,
          new_password: 'newpassword123'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for missing temporary password' do
        post '/api/v1/password/reset', params: {
          email: user.email,
          new_password: 'newpassword123'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for missing new password' do
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: user.temp_password
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for non-existent user' do
        post '/api/v1/password/reset', params: {
          email: 'nonexistent@example.com',
          temp_password: 'sometemp',
          new_password: 'newpassword123'
        }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context 'password confirmation handling' do
      it 'uses new_password as confirmation if not provided' do
        temp_password = user.temp_password
        
        post '/api/v1/password/reset', params: {
          email: user.email,
          temp_password: temp_password,
          new_password: 'newpassword123'
        }
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

