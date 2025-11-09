require 'rails_helper'

RSpec.describe Api::V1::LoyaltyPointsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #show' do
    it 'returns user loyalty points balance' do
      loyalty_point = create(:loyalty_point, user: user, points_balance: 500)
      get :show
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['points_balance']).to eq(500)
    end
  end

  describe 'GET #transactions' do
    it 'returns loyalty points transactions' do
      loyalty_point = create(:loyalty_point, user: user)
      create(:loyalty_points_transaction, user: user, points: 100)
      
      get :transactions
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end
end
