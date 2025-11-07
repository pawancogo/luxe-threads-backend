# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Support Tickets API', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  
  describe 'GET /api/v1/support_tickets' do
    before do
      create_list(:support_ticket, 3, user: user)
    end
    
    it 'returns user support tickets' do
      get '/api/v1/support_tickets', headers: auth_headers
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data'].length).to eq(3)
    end
    
    it 'filters by status' do
      create(:support_ticket, user: user, status: 'resolved')
      get '/api/v1/support_tickets', params: { status: 'open' }, headers: auth_headers
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |t| t['status'] == 'open' }).to be true
    end
  end
  
  describe 'POST /api/v1/support_tickets' do
    let(:ticket_params) do
      {
        support_ticket: {
          subject: 'Test Ticket',
          description: 'This is a test ticket',
          category: 'order_issue',
          priority: 'medium'
        }
      }
    end
    
    it 'creates a support ticket' do
      expect {
        post '/api/v1/support_tickets', params: ticket_params, headers: auth_headers
      }.to change(SupportTicket, :count).by(1)
      
      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['subject']).to eq('Test Ticket')
    end
    
    it 'creates initial message' do
      post '/api/v1/support_tickets', params: ticket_params, headers: auth_headers
      
      ticket = SupportTicket.last
      expect(ticket.support_ticket_messages.count).to eq(1)
      expect(ticket.support_ticket_messages.first.message).to include('This is a test ticket')
    end
  end
  
  describe 'POST /api/v1/support_tickets/:id/messages' do
    let(:ticket) { create(:support_ticket, user: user) }
    let(:message_params) do
      {
        message: {
          message: 'This is a reply'
        }
      }
    end
    
    it 'creates a message on the ticket' do
      expect {
        post "/api/v1/support_tickets/#{ticket.id}/messages", 
             params: message_params, 
             headers: auth_headers
      }.to change(SupportTicketMessage, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end
end

