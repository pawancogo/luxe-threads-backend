require 'rails_helper'

RSpec.describe Api::V1::SupplierProfilesController, type: :controller do
  let(:supplier) { create(:supplier) }
  let(:supplier_profile) { create(:supplier_profile, supplier: supplier) }
  let(:token) { JsonWebToken.encode(supplier_id: supplier.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #show' do
    it 'returns supplier profile details' do
      get :show, params: { id: supplier_profile.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(supplier_profile.id)
    end
  end

  describe 'PATCH #update' do
    it 'updates supplier profile' do
      patch :update, params: { 
        id: supplier_profile.id,
        supplier_profile: { company_name: 'Updated Company' } 
      }
      
      expect(response).to have_http_status(:success)
      expect(supplier_profile.reload.company_name).to eq('Updated Company')
    end
  end
end
