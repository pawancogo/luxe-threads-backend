require 'rails_helper'

RSpec.describe Api::V1::SupplierProfilesController, type: :controller do
  let(:supplier) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier) }

  before do
    allow(controller).to receive(:current_user).and_return(supplier)
    allow(controller).to receive(:authenticate_request)
    # Ensure supplier has a supplier_profile
    supplier.supplier_profile = supplier_profile
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::SupplierProfilesController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authorize_supplier! before_action' do
      expect(Api::V1::SupplierProfilesController._process_action_callbacks.map(&:filter)).to include(:authorize_supplier!)
    end
  end

  describe 'GET #show' do
    it 'returns supplier profile' do
      supplier_profile
      get :show
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('company_name')
    end

    it 'returns 404 when profile not found' do
      # Remove the supplier_profile to test the not found case
      supplier.supplier_profile = nil
      get :show
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to have_key('error')
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        supplier_profile: {
          company_name: 'Test Company',
          gst_number: 'GST123456789',
          description: 'Test Description',
          website_url: 'https://test.com'
        }
      }
    end

    it 'creates supplier profile with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('company_name')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(supplier_profile: { company_name: '' })
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        supplier_profile: {
          company_name: 'Updated Company',
          description: 'Updated Description'
        }
      }
    end

    it 'updates supplier profile with valid params' do
      supplier_profile
      patch :update, params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['company_name']).to eq('Updated Company')
    end

    it 'returns error with invalid params' do
      supplier_profile
      invalid_params = valid_params.merge(supplier_profile: { company_name: '' })
      patch :update, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe 'authorization' do
    it 'returns unauthorized for non-supplier' do
      customer = create(:user)
      allow(controller).to receive(:current_user).and_return(customer)
      get :show
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end
  end
end