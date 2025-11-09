require 'rails_helper'

RSpec.describe Api::V1::PasswordResetController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST #forgot' do
    it 'sends password reset email for valid user' do
      expect {
        post :forgot, params: { email: user.email }
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    it 'returns success even for invalid email (security)' do
      post :forgot, params: { email: 'nonexistent@example.com' }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    it 'returns error for blank email' do
      post :forgot, params: { email: '' }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #reset' do
    before do
      user.send_password_reset_email
      user.reload
    end

    it 'resets password with valid temporary password' do
      temp_password = user.temp_password
      new_password = 'newpassword123'
      
      post :reset, params: {
        email: user.email,
        temp_password: temp_password,
        new_password: new_password,
        password_confirmation: new_password
      }
      
      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.authenticate(new_password)).to be_truthy
    end

    it 'returns error for invalid temporary password' do
      post :reset, params: {
        email: user.email,
        temp_password: 'wrong_password',
        new_password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error when passwords do not match' do
      temp_password = user.temp_password
      
      post :reset, params: {
        email: user.email,
        temp_password: temp_password,
        new_password: 'newpassword123',
        password_confirmation: 'differentpassword'
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

