require 'rails_helper'

RSpec.describe Api::V1::AddressesController, type: :controller do
  let(:user) { create(:user) }
  let(:address) { create(:address, user: user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request)
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::AddressesController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has set_address before_action' do
      expect(Api::V1::AddressesController._process_action_callbacks.map(&:filter)).to include(:set_address)
    end
  end

  describe 'GET #index' do
    it 'returns user addresses' do
      address
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        address: {
          address_type: 'shipping',
          full_name: 'John Doe',
          phone_number: '1234567890',
          line1: '123 Main St',
          city: 'New York',
          state: 'NY',
          postal_code: '10001',
          country: 'USA'
        }
      }
    end

    it 'creates address with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('full_name')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(address: { full_name: '' })
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('full_name')
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        id: address.id,
        address: { full_name: 'Jane Doe' }
      }
    end

    it 'updates address with valid params' do
      patch :update, params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['full_name']).to eq('Jane Doe')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(address: { full_name: '' })
      patch :update, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('full_name')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys address' do
      delete :destroy, params: { id: address.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'raises exception for non-existent address' do
      expect { delete :destroy, params: { id: 999 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end