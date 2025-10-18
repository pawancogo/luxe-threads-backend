require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
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
      expect(Api::V1::OrdersController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has set_order before_action' do
      expect(Api::V1::OrdersController._process_action_callbacks.map(&:filter)).to include(:set_order)
    end
  end

  describe 'GET #index' do
    it 'returns user orders' do
      order
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns order with order items' do
      get :show, params: { id: order.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('order_items')
    end

    it 'raises exception for non-existent order' do
      expect { get :show, params: { id: 999 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        order: {
          shipping_address_id: create(:address, user: user).id,
          billing_address_id: create(:address, user: user).id,
          shipping_method: 'standard',
          payment_method_id: 'pm_test'
        }
      }
    end

    before do
      cart_item
      allow(Stripe::PaymentIntent).to receive(:create).and_return(double(client_secret: 'test_secret'))
    end

    it 'creates order with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('order')
    end

    it 'returns error for empty cart' do
      cart.cart_items.destroy_all
      post :create, params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('error')
    end

    it 'handles Stripe errors' do
      allow(Stripe::PaymentIntent).to receive(:create).and_raise(Stripe::CardError.new('Card declined', 'card_declined'))
      post :create, params: valid_params
      expect(response).to have_http_status(:payment_required)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end
end
