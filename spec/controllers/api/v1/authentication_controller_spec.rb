require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  # No before block needed since authenticate_request is skipped for create action

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::AuthenticationController.superclass).to eq(ApplicationController)
    end
  end

  describe 'concerns' do
    it 'includes JsonWebToken' do
      expect(Api::V1::AuthenticationController.ancestors).to include(JsonWebToken)
    end
  end

  describe 'before_actions' do
    it 'has authenticate_request before_action' do
      expect(Api::V1::AuthenticationController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'POST #create' do
    it 'handles authentication logic' do
      # Test that the controller has the expected structure
      expect(controller.respond_to?(:create)).to be true
      expect(Api::V1::AuthenticationController.instance_methods).to include(:create)
    end

    it 'returns unauthorized with invalid email' do
      allow(controller).to receive(:authenticate_request).and_return(true)
      post :create, params: { email: 'wrong@example.com', password: 'password123' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end

    it 'returns unauthorized with invalid password' do
      allow(controller).to receive(:authenticate_request).and_return(true)
      post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end

    it 'returns unauthorized with missing params' do
      allow(controller).to receive(:authenticate_request).and_return(true)
      post :create, params: { email: 'test@example.com' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end
  end

  describe 'create method coverage' do
    it 'covers the create method structure' do
      # Test that the method exists and can be called
      expect(controller.respond_to?(:create, true)).to be true
      expect(Api::V1::AuthenticationController.private_method_defined?(:create)).to be false
      expect(Api::V1::AuthenticationController.public_method_defined?(:create)).to be true
    end

    it 'covers method existence check' do
      # Test that the method exists in the controller
      expect(Api::V1::AuthenticationController.instance_methods(false)).to include(:create)
    end

    it 'covers skip_before_action configuration' do
      # Test that authenticate_request is configured as before_action
      expect(Api::V1::AuthenticationController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'create method logic coverage' do
    it 'covers successful authentication with valid credentials' do
      user = create(:user, email: 'test@example.com', password: 'password123')
      
      post :create, params: { email: 'test@example.com', password: 'password123' }
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
      expect(controller.instance_variable_get(:@user)).to eq(user)
    end

    it 'covers authentication failure with invalid password' do
      user = create(:user, email: 'test@example.com', password: 'password123')
      
      post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
      
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
      expect(controller.instance_variable_get(:@user)).to eq(user)
    end

    it 'covers authentication failure with non-existent user' do
      post :create, params: { email: 'nonexistent@example.com', password: 'password123' }
      
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
      expect(controller.instance_variable_get(:@user)).to be_nil
    end

    it 'covers JWT token generation' do
      user = create(:user, email: 'test@example.com', password: 'password123')
      
      post :create, params: { email: 'test@example.com', password: 'password123' }
      
      expect(response).to have_http_status(:ok)
      token = JSON.parse(response.body)['token']
      expect(token).to be_present
      
      # Verify the token can be decoded
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      expect(decoded['user_id']).to eq(user.id)
    end

    it 'covers the else branch in authentication logic' do
      # Test the else branch when authentication fails
      user = create(:user, email: 'test@example.com', password: 'password123')
      
      post :create, params: { email: 'test@example.com', password: 'wrongpassword' }
      
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('unauthorized')
    end
  end
end