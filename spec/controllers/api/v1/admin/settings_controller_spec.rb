require 'rails_helper'

RSpec.describe Api::V1::Admin::SettingsController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all settings' do
      create_list(:setting, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'GET #show' do
    let(:setting) { create(:setting) }

    it 'returns setting details' do
      get :show, params: { key: setting.key }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['key']).to eq(setting.key)
    end
  end

  describe 'PUT #update' do
    let(:setting) { create(:setting, value: 'old_value') }

    it 'updates setting value' do
      put :update, params: { key: setting.key, setting: { value: 'new_value' } }
      
      expect(response).to have_http_status(:ok)
      setting.reload
      expect(setting.value).to eq('new_value')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

