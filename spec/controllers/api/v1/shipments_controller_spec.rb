require 'rails_helper'

RSpec.describe Api::V1::ShipmentsController, type: :controller do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #index' do
    it 'returns user shipments' do
      shipment = create(:shipment, order: order)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns shipment details' do
      shipment = create(:shipment, order: order)
      get :show, params: { id: shipment.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(shipment.id)
    end
  end

  describe 'GET #track' do
    it 'returns shipment tracking information' do
      shipment = create(:shipment, order: order, tracking_number: 'TRACK123')
      get :track, params: { id: shipment.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to have_key('tracking_number')
    end
  end
end
