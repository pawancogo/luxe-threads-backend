require 'rails_helper'

RSpec.describe Api::V1::CartsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #show' do
    it 'returns user cart' do
      cart = create(:cart, user: user)
      get :show
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_a(Hash)
    end
  end

  describe 'DELETE #destroy' do
    it 'clears cart items' do
      cart = create(:cart, user: user)
      create(:cart_item, cart: cart)
      
      delete :destroy
      
      expect(response).to have_http_status(:success)
      expect(cart.cart_items.count).to eq(0)
    end
  end
end
