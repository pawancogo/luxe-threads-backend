require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe 'GET #index' do
    it 'returns all categories' do
      create_list(:category, 3)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'returns active categories only' do
      create(:category, active: true)
      create(:category, active: false)
      
      get :index, params: { active: 'true' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |c| c['active'] }).to be true
    end
  end

  describe 'GET #show' do
    it 'returns category details' do
      category = create(:category)
      get :show, params: { id: category.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(category.id)
    end
  end
end
