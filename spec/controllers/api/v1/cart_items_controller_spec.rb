require 'rails_helper'

RSpec.describe Api::V1::CartItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }
  let(:product_variant) { create(:product_variant) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'POST #create' do
    it 'creates a new cart item' do
      post :create, params: { 
        cart_item: { 
          product_variant_id: product_variant.id, 
          quantity: 2 
        } 
      }
      
      expect(response).to have_http_status(:created)
      expect(CartItem.count).to eq(1)
    end

    it 'returns validation errors for invalid cart item' do
      post :create, params: { cart_item: { quantity: 0 } }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    let(:cart_item) { create(:cart_item, cart: cart, product_variant: product_variant) }

    it 'updates cart item quantity' do
      patch :update, params: { id: cart_item.id, cart_item: { quantity: 5 } }
      
      expect(response).to have_http_status(:success)
      expect(cart_item.reload.quantity).to eq(5)
    end
  end

  describe 'DELETE #destroy' do
    let(:cart_item) { create(:cart_item, cart: cart) }

    it 'deletes cart item' do
      delete :destroy, params: { id: cart_item.id }
      
      expect(response).to have_http_status(:success)
      expect(CartItem.exists?(cart_item.id)).to be false
    end
  end
end
