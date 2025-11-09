require 'rails_helper'

RSpec.describe Api::V1::PromotionsController, type: :controller do
  describe 'GET #index' do
    it 'returns active promotions' do
      create_list(:promotion, 3, active: true)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'filters active promotions only' do
      active = create(:promotion, active: true)
      inactive = create(:promotion, active: false)
      
      get :index
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].map { |p| p['id'] }).to include(active.id)
      expect(json_response['data'].map { |p| p['id'] }).not_to include(inactive.id)
    end
  end

  describe 'GET #show' do
    it 'returns promotion details' do
      promotion = create(:promotion)
      get :show, params: { id: promotion.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(promotion.id)
    end
  end
end
