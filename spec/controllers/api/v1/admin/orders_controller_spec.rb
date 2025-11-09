require 'rails_helper'

RSpec.describe Api::V1::Admin::OrdersController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all orders' do
      create_list(:order, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end

    it 'filters by status' do
      create(:order, status: 'pending')
      create(:order, status: 'confirmed')
      
      get :index, params: { status: 'pending' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |o| o['status'] == 'pending' }).to be true
    end
  end

  describe 'GET #show' do
    let(:order) { create(:order) }

    it 'returns order details' do
      get :show, params: { id: order.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(order.id)
    end
  end

  describe 'PATCH #update_status' do
    let(:order) { create(:order, status: 'pending') }

    it 'updates order status' do
      patch :update_status, params: { id: order.id, status: 'confirmed' }
      
      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.status).to eq('confirmed')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

