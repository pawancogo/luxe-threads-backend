require 'rails_helper'

RSpec.describe Api::V1::BrandsController, type: :controller do
  describe 'GET #index' do
    it 'returns all brands' do
      create_list(:brand, 3)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].length).to eq(3)
    end

    it 'filters active brands' do
      create(:brand, active: true)
      create(:brand, active: false)
      
      get :index, params: { active: 'true' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |b| b['active'] }).to be true
    end
  end

  describe 'GET #show' do
    it 'returns brand details' do
      brand = create(:brand)
      get :show, params: { id: brand.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(brand.id)
    end
  end
end
