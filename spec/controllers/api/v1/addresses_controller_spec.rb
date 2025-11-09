require 'rails_helper'

RSpec.describe Api::V1::AddressesController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #index' do
    it 'returns user addresses' do
      address = create(:address, user: user)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'POST #create' do
    it 'creates a new address' do
      address_params = attributes_for(:address, user_id: user.id)
      post :create, params: { address: address_params }
      
      expect(response).to have_http_status(:created)
      expect(Address.count).to eq(1)
    end

    it 'returns validation errors for invalid address' do
      post :create, params: { address: { street: '' } }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    let(:address) { create(:address, user: user) }

    it 'updates address' do
      patch :update, params: { id: address.id, address: { street: 'New Street' } }
      
      expect(response).to have_http_status(:success)
      expect(address.reload.street).to eq('New Street')
    end
  end

  describe 'DELETE #destroy' do
    let(:address) { create(:address, user: user) }

    it 'deletes address' do
      delete :destroy, params: { id: address.id }
      
      expect(response).to have_http_status(:success)
      expect(Address.exists?(address.id)).to be false
    end
  end
end
