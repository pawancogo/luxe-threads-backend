require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe 'GET #index' do
    it 'returns all products' do
      create_list(:product, 3, status: 'active')
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'filters by category' do
      category = create(:category)
      product = create(:product, category: category, status: 'active')
      other_product = create(:product, status: 'active')
      
      get :index, params: { category_id: category.id }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].map { |p| p['id'] }).to include(product.id)
    end
  end

  describe 'GET #show' do
    it 'returns product details' do
      product = create(:product, status: 'active')
      get :show, params: { id: product.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(product.id)
    end
  end
end
