# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications API', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  
  describe 'GET /api/v1/notifications' do
    context 'when authenticated' do
      before do
        create_list(:notification, 5, user: user, is_read: false)
        create_list(:notification, 3, user: user, is_read: true)
      end
      
      it 'returns user notifications' do
        get '/api/v1/notifications', headers: auth_headers
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data'].length).to eq(8)
      end
      
      it 'filters by read status' do
        get '/api/v1/notifications', params: { is_read: false }, headers: auth_headers
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].all? { |n| n['is_read'] == false }).to be true
      end
    end
    
    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/notifications'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET /api/v1/notifications/unread_count' do
    before do
      create_list(:notification, 3, user: user, is_read: false)
      create_list(:notification, 2, user: user, is_read: true)
    end
    
    it 'returns unread count' do
      get '/api/v1/notifications/unread_count', headers: auth_headers
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['unread_count']).to eq(3)
    end
  end
  
  describe 'PATCH /api/v1/notifications/:id/mark_as_read' do
    let(:notification) { create(:notification, user: user, is_read: false) }
    
    it 'marks notification as read' do
      patch "/api/v1/notifications/#{notification.id}/mark_as_read", headers: auth_headers
      
      expect(response).to have_http_status(:success)
      notification.reload
      expect(notification.is_read).to be true
      expect(notification.read_at).to be_present
    end
  end
  
  describe 'PATCH /api/v1/notifications/mark_all_read' do
    before do
      create_list(:notification, 5, user: user, is_read: false)
    end
    
    it 'marks all notifications as read' do
      patch '/api/v1/notifications/mark_all_read', headers: auth_headers
      
      expect(response).to have_http_status(:success)
      expect(user.notifications.where(is_read: false).count).to eq(0)
    end
  end
end

