require 'rails_helper'

RSpec.describe Api::V1::SupportTicketMessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:ticket) { create(:support_ticket, user: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'POST #create' do
    it 'creates message for ticket' do
      expect {
        post :create, params: {
          support_ticket_id: ticket.id,
          support_ticket_message: {
            message: 'Test message'
          }
        }
      }.to change(SupportTicketMessage, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

