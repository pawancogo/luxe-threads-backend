require 'rails_helper'

RSpec.describe Api::V1::SupplierReturnsController, type: :controller do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns supplier return requests' do
      order_item = create(:order_item, supplier_profile: supplier_profile)
      return_request = create(:return_request, order_item: order_item)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'PATCH #approve' do
    let(:order_item) { create(:order_item, supplier_profile: supplier_profile) }
    let(:return_request) { create(:return_request, order_item: order_item, status: 'requested') }

    it 'approves return request' do
      patch :approve, params: { id: return_request.id }
      
      expect(response).to have_http_status(:ok)
      return_request.reload
      expect(return_request.status).to eq('approved')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

