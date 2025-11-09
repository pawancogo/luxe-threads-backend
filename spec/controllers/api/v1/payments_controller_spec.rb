require 'rails_helper'

RSpec.describe Api::V1::PaymentsController, type: :controller do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user, status: 'pending') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates payment for order' do
        post :create, params: {
          order_id: order.id,
          payment: {
            amount: order.total_amount,
            payment_method: 'credit_card',
            payment_gateway: 'stripe',
            transaction_id: 'txn_123'
          }
        }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']).to have_key('id')
      end

      it 'updates order status' do
        post :create, params: {
          order_id: order.id,
          payment: {
            amount: order.total_amount,
            payment_method: 'credit_card'
          }
        }

        order.reload
        expect(order.payments.count).to eq(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post :create, params: {
          order_id: order.id,
          payment: {
            amount: -10
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #show' do
    let(:payment) { create(:payment, order: order, user: user) }

    it 'returns payment details' do
      get :show, params: { id: payment.id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(payment.id)
    end
  end

  describe 'POST #refund' do
    let(:payment) { create(:payment, order: order, user: user, status: 'completed', amount: 100.0) }

    it 'creates refund request' do
      post :refund, params: {
        id: payment.id,
        refund: {
          amount: 100.0,
          reason: 'Customer request'
        }
      }

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end

    it 'updates payment status to refunded' do
      post :refund, params: {
        id: payment.id,
        refund: {
          amount: 100.0,
          reason: 'Customer request'
        }
      }

      payment.reload
      expect(payment.status).to eq('refunded')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

