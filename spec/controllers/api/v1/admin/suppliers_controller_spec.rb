require 'rails_helper'

RSpec.describe Api::V1::Admin::SuppliersController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all suppliers' do
      create_list(:supplier_profile, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:supplier_profile) { create(:supplier_profile) }

    it 'returns supplier details' do
      get :show, params: { id: supplier_profile.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(supplier_profile.id)
    end
  end

  describe 'PATCH #approve' do
    let(:supplier_profile) { create(:supplier_profile, verified: false) }

    it 'approves supplier' do
      patch :approve, params: { id: supplier_profile.id }
      
      expect(response).to have_http_status(:ok)
      supplier_profile.reload
      expect(supplier_profile.verified).to be true
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

