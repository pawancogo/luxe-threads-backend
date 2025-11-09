require 'rails_helper'

RSpec.describe Api::V1::NotificationPreferencesController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #show' do
    it 'returns notification preferences' do
      create(:notification_preference, user: user)
      
      get :show
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'PATCH #update' do
    let(:preference) { create(:notification_preference, user: user) }

    it 'updates notification preferences' do
      patch :update, params: {
        notification_preference: {
          preferences: { email: { order_updates: false } }.to_json
        }
      }
      
      expect(response).to have_http_status(:ok)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

