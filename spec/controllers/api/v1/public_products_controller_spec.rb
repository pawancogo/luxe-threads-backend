require 'rails_helper'

RSpec.describe Api::V1::PublicProductsController, type: :controller do
  describe 'GET #index' do
    it 'returns public products without authentication' do
      create_list(:product, 3, status: 'active')
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    it 'filters products by category' do
      category = create(:category)
      create(:product, category: category, status: 'active')
      create(:product, status: 'active')
      
      get :index, params: { category_id: category.id }
      
      expect(response).to have_http_status(:ok)
    end

    it 'filters products by brand' do
      brand = create(:brand)
      create(:product, brand: brand, status: 'active')
      create(:product, status: 'active')
      
      get :index, params: { brand_id: brand.id }
      
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    let(:product) { create(:product, status: 'active') }

    it 'returns product details without authentication' do
      get :show, params: { id: product.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(product.id)
    end

    it 'returns product by slug' do
      product.update(slug: 'test-product')
      
      get :show, params: { id: 'test-product' }
      
      expect(response).to have_http_status(:ok)
    end
  end
end

