# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Product Views API', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  
  describe 'POST /api/v1/products/:id/views' do
    context 'when authenticated' do
      it 'tracks product view' do
        expect {
          post "/api/v1/products/#{product.id}/views",
               params: { product_view: { source: 'direct' } },
               headers: auth_headers
        }.to change(ProductView, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
      
      it 'tracks with product variant' do
        variant = create(:product_variant, product: product)
        
        post "/api/v1/products/#{product.id}/views",
             params: { product_view: { product_variant_id: variant.id, source: 'search' } },
             headers: auth_headers
        
        expect(response).to have_http_status(:created)
        view = ProductView.last
        expect(view.product_variant_id).to eq(variant.id)
      end
    end
    
    context 'when not authenticated' do
      it 'tracks anonymous view with session_id' do
        expect {
          post "/api/v1/products/#{product.id}/views",
               params: { product_view: { session_id: 'test_session_123', source: 'direct' } }
        }.to change(ProductView, :count).by(1)
        
        expect(response).to have_http_status(:created)
        view = ProductView.last
        expect(view.user_id).to be_nil
        expect(view.session_id).to eq('test_session_123')
      end
    end
  end
end

