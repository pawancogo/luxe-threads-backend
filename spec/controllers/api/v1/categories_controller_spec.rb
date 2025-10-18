require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::CategoriesController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authenticate_request before_action' do
      expect(Api::V1::CategoriesController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'GET #index' do
    it 'returns all categories' do
      create_list(:category, 3)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
      expect(JSON.parse(response.body).length).to eq(3)
    end

    it 'returns empty array when no categories' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end