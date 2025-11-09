require 'rails_helper'

RSpec.describe Api::V1::ProductVariantsController, type: :controller do
  describe 'GET #index' do
    it 'returns product variants' do
      product = create(:product)
      create_list(:product_variant, 3, product: product)
      
      get :index, params: { product_id: product.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns product variant details' do
      product_variant = create(:product_variant)
      get :show, params: { id: product_variant.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(product_variant.id)
    end
  end
end
