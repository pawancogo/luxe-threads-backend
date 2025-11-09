require 'rails_helper'

RSpec.describe Api::V1::SupportTicketsController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns user support tickets' do
      create(:support_ticket, user: user)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'POST #create' do
    it 'creates support ticket' do
      expect {
        post :create, params: {
          support_ticket: {
            subject: 'Test Issue',
            description: 'Test description',
            priority: 'medium'
          }
        }
      }.to change(SupportTicket, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end

  describe 'GET #show' do
    let(:ticket) { create(:support_ticket, user: user) }

    it 'returns ticket details' do
      get :show, params: { id: ticket.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(ticket.id)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

