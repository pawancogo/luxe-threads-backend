require 'rails_helper'

RSpec.describe Api::V1::CartsController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let(:product) { create(:product) }
  let(:product_variant) { create(:product_variant, product: product) }
  let(:cart_item) { create(:cart_item, cart: cart, product_variant: product_variant) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request)
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::CartsController.superclass).to eq(ApplicationController)
    end
  end

  describe 'GET #show' do
    it 'returns cart items with product and brand info' do
      cart_item
      get :show
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'returns empty array for empty cart' do
      get :show
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end