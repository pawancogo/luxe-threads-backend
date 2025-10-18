require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  let(:admin_user) { create(:user, :admin) }
  let(:customer) { create(:user) }

  before do
    allow(controller).to receive(:authenticate_request)
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(AdminController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authenticate_request before_action' do
      expect(AdminController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'GET #login' do
    it 'renders login form' do
      get :login
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Admin Login')
      expect(response.body).to include('email')
      expect(response.body).to include('password')
    end
  end

  describe 'POST #authenticate' do
    it 'authenticates admin user' do
      post :authenticate, params: { email: admin_user.email, password: 'password123' }
      expect(response).to have_http_status(:redirect)
      expect(session[:admin_user_id]).to eq(admin_user.id)
    end

    it 'rejects non-admin user' do
      post :authenticate, params: { email: customer.email, password: 'password123' }
      expect(response).to have_http_status(:redirect)
      expect(session[:admin_user_id]).to be_nil
    end

    it 'rejects invalid credentials' do
      post :authenticate, params: { email: admin_user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:redirect)
      expect(session[:admin_user_id]).to be_nil
    end

    it 'rejects non-existent user' do
      post :authenticate, params: { email: 'nonexistent@example.com', password: 'password123' }
      expect(response).to have_http_status(:redirect)
      expect(session[:admin_user_id]).to be_nil
    end
  end

  describe 'DELETE #logout' do
    it 'clears admin session' do
      session[:admin_user_id] = admin_user.id
      delete :logout
      expect(response).to have_http_status(:redirect)
      expect(session[:admin_user_id]).to be_nil
    end
  end
end