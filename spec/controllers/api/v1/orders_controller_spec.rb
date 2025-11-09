require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns user orders' do
      create_list(:order, 3, user: user)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end

    it 'filters by status' do
      create(:order, user: user, status: 'pending')
      create(:order, user: user, status: 'confirmed')
      
      get :index, params: { status: 'pending' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |o| o['status'] == 'pending' }).to be true
    end
  end

  describe 'GET #show' do
    let(:order) { create(:order, user: user) }

    it 'returns order details' do
      get :show, params: { id: order.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(order.id)
    end
  end

  describe 'POST #create' do
    let(:address) { create(:address, user: user) }
    let(:cart_item) { create(:cart_item, cart: cart) }

    it 'creates order from cart' do
      expect {
        post :create, params: {
          order: {
            shipping_address_id: address.id,
            billing_address_id: address.id
          }
        }
      }.to change(Order, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #cancel' do
    let(:order) { create(:order, user: user, status: 'pending') }

    it 'cancels order' do
      patch :cancel, params: { id: order.id }
      
      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.status).to eq('cancelled')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
