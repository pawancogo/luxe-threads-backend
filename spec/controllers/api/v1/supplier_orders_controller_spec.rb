require 'rails_helper'

RSpec.describe Api::V1::SupplierOrdersController, type: :controller do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
  let(:customer) { create(:user) }
  let(:order) { create(:order, user: customer) }
  let(:order_item) { create(:order_item, order: order, supplier_profile: supplier_profile) }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns supplier orders' do
      order_item
      get :index

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data'].length).to eq(1)
    end

    it 'only returns orders for current supplier' do
      other_supplier = create(:supplier_profile)
      other_order_item = create(:order_item, supplier_profile: other_supplier)
      order_item

      get :index

      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'].first['supplier_profile_id']).to eq(supplier_profile.id)
    end
  end

  describe 'GET #show' do
    it 'returns order item details' do
      get :show, params: { item_id: order_item.id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(order_item.id)
    end

    it 'returns not found for other supplier order' do
      other_supplier = create(:supplier_profile)
      other_order_item = create(:order_item, supplier_profile: other_supplier)

      get :show, params: { item_id: other_order_item.id }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #confirm' do
    it 'confirms order item' do
      post :confirm, params: { item_id: order_item.id }

      expect(response).to have_http_status(:ok)
      order_item.reload
      expect(order_item.fulfillment_status).to eq('processing')
    end
  end

  describe 'PUT #ship' do
    before do
      order_item.update(fulfillment_status: 'processing')
    end

    it 'ships order item' do
      put :ship, params: {
        item_id: order_item.id,
        tracking_number: 'TRACK123',
        shipping_provider: 'FedEx'
      }

      expect(response).to have_http_status(:ok)
      order_item.reload
      expect(order_item.fulfillment_status).to eq('shipped')
      expect(order_item.tracking_number).to eq('TRACK123')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

