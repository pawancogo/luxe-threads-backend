require 'rails_helper'

RSpec.describe Api::V1::PaymentRefundsController, type: :controller do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let(:payment) { create(:payment, order: order) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns user refunds' do
      refund = create(:payment_refund, payment: payment)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'POST #create' do
    it 'creates refund request' do
      expect {
        post :create, params: {
          payment_id: payment.id,
          payment_refund: {
            amount: 100.0,
            reason: 'Product defect'
          }
        }
      }.to change(PaymentRefund, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end

  describe 'GET #show' do
    let(:refund) { create(:payment_refund, payment: payment) }

    it 'returns refund details' do
      get :show, params: { id: refund.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(refund.id)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

