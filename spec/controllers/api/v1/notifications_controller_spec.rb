require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'GET #index' do
    it 'returns user notifications' do
      create_list(:notification, 3, user: user)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'filters unread notifications' do
      unread = create(:notification, user: user, is_read: false)
      read = create(:notification, user: user, is_read: true)
      
      get :index, params: { unread: 'true' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].map { |n| n['id'] }).to include(unread.id)
      expect(json_response['data'].map { |n| n['id'] }).not_to include(read.id)
    end
  end

  describe 'PATCH #mark_as_read' do
    it 'marks notification as read' do
      notification = create(:notification, user: user, is_read: false)
      patch :mark_as_read, params: { id: notification.id }
      
      expect(response).to have_http_status(:success)
      expect(notification.reload.is_read).to be true
    end
  end
end
