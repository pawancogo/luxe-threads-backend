require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all users' do
      create_list(:user, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }

    it 'returns user details' do
      get :show, params: { id: user.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(user.id)
    end
  end

  describe 'PATCH #activate' do
    let(:user) { create(:user, is_active: false) }

    it 'activates user' do
      patch :activate, params: { id: user.id }
      
      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.is_active).to be true
    end
  end

  describe 'PATCH #deactivate' do
    let(:user) { create(:user, is_active: true) }

    it 'deactivates user' do
      patch :deactivate, params: { id: user.id }
      
      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.is_active).to be false
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

