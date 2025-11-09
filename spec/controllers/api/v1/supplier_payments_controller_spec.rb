require 'rails_helper'

RSpec.describe Api::V1::SupplierPaymentsController, type: :controller do
  let(:supplier) { create(:supplier) }
  let(:supplier_profile) { create(:supplier_profile, supplier: supplier) }
  let(:token) { JsonWebToken.encode(supplier_id: supplier.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #index' do
    it 'returns supplier payments' do
      payment = create(:supplier_payment, supplier_profile: supplier_profile)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns payment details' do
      payment = create(:supplier_payment, supplier_profile: supplier_profile)
      get :show, params: { id: payment.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(payment.id)
    end
  end
end
