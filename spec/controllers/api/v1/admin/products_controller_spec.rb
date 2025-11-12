require 'rails_helper'

RSpec.describe Api::V1::Admin::ProductsController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all products' do
      create_list(:product, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end

    it 'filters by status' do
      create(:product, status: 'active')
      create(:product, status: 'pending')
      
      get :index, params: { status: 'active' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |p| p['status'] == 'active' }).to be true
    end
  end

  describe 'GET #show' do
    let(:product) { create(:product) }

    it 'returns product details' do
      get :show, params: { id: product.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(product.id)
    end
  end

  describe 'PATCH #approve' do
    let(:product) { create(:product, status: 'pending') }

    it 'approves product' do
      patch :approve, params: { id: product.id }
      
      expect(response).to have_http_status(:ok)
      product.reload
      expect(product.status).to eq('active')
    end
  end

  describe 'PATCH #reject' do
    let(:product) { create(:product, status: 'pending') }

    it 'rejects product' do
      patch :reject, params: { id: product.id, reason: 'Invalid product' }
      
      expect(response).to have_http_status(:ok)
      product.reload
      expect(product.status).to eq('rejected')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





