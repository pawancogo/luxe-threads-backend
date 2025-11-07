# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Loyalty Points API', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  
  describe 'GET /api/v1/loyalty_points/balance' do
    before do
      create(:loyalty_points_transaction, user: user, transaction_type: 'earned', points: 100)
      create(:loyalty_points_transaction, user: user, transaction_type: 'redeemed', points: 30)
    end
    
    it 'returns loyalty points balance' do
      get '/api/v1/loyalty_points/balance', headers: auth_headers
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data']['balance']).to eq(70)
    end
  end
  
  describe 'GET /api/v1/loyalty_points' do
    before do
      create_list(:loyalty_points_transaction, 5, user: user, transaction_type: 'earned')
      create_list(:loyalty_points_transaction, 2, user: user, transaction_type: 'redeemed')
    end
    
    it 'returns loyalty points transactions' do
      get '/api/v1/loyalty_points', headers: auth_headers
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(7)
    end
    
    it 'filters by transaction type' do
      get '/api/v1/loyalty_points', params: { transaction_type: 'earned' }, headers: auth_headers
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |t| t['transaction_type'] == 'earned' }).to be true
    end
  end
end

