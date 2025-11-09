require 'rails_helper'

RSpec.describe Api::V1::SupplierAnalyticsController, type: :controller do
  let(:supplier) { create(:supplier) }
  let(:supplier_profile) { create(:supplier_profile, supplier: supplier) }
  let(:token) { JsonWebToken.encode(supplier_id: supplier.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #dashboard' do
    it 'returns supplier analytics dashboard data' do
      get :dashboard
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_a(Hash)
    end
  end

  describe 'GET #sales' do
    it 'returns sales analytics' do
      get :sales, params: { start_date: 1.month.ago, end_date: Date.today }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_a(Hash)
    end
  end

  describe 'GET #products' do
    it 'returns product analytics' do
      get :products
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_a(Hash)
    end
  end
end
