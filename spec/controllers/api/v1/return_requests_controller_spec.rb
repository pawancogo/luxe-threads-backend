require 'rails_helper'

RSpec.describe Api::V1::ReturnRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user, status: 'delivered') }
  let(:order_item) { create(:order_item, order: order, is_returnable: true) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns user return requests' do
      return_request = create(:return_request, order_item: order_item)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data'].length).to eq(1)
    end
  end

  describe 'GET #show' do
    let(:return_request) { create(:return_request, order_item: order_item) }

    it 'returns return request details' do
      get :show, params: { id: return_request.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(return_request.id)
    end
  end

  describe 'POST #create' do
    it 'creates return request' do
      expect {
        post :create, params: {
          return_request: {
            order_item_id: order_item.id,
            return_reason: 'Defective product',
            return_quantity: 1
          }
        }
      }.to change(ReturnRequest, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end

    it 'returns error for non-returnable item' do
      non_returnable = create(:order_item, order: order, is_returnable: false)
      
      post :create, params: {
        return_request: {
          order_item_id: non_returnable.id,
          return_reason: 'Defective',
          return_quantity: 1
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





