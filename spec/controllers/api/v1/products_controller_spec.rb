require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let(:supplier) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier) }
  let(:product) { create(:product, supplier_profile: supplier_profile) }

  before do
    allow(controller).to receive(:current_user).and_return(supplier)
    allow(controller).to receive(:authenticate_request)
    # Ensure supplier has a supplier_profile
    supplier.supplier_profile = supplier_profile
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::ProductsController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authorize_supplier! before_action' do
      expect(Api::V1::ProductsController._process_action_callbacks.map(&:filter)).to include(:authorize_supplier!)
    end

    it 'has set_product before_action' do
      expect(Api::V1::ProductsController._process_action_callbacks.map(&:filter)).to include(:set_product)
    end
  end

  describe 'GET #index' do
    it 'returns supplier products' do
      product
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns product' do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('id')
    end

    it 'raises exception for non-existent product' do
      expect { get :show, params: { id: 999 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        product: {
          name: 'Test Product',
          description: 'Test Description',
          category_id: create(:category).id,
          brand_id: create(:brand).id
        }
      }
    end

    it 'creates product with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('name')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(product: { name: '' })
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('name')
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        id: product.id,
        product: { name: 'Updated Product' }
      }
    end

    it 'updates product with valid params' do
      patch :update, params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq('Updated Product')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(product: { name: '' })
      patch :update, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('name')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys product' do
      delete :destroy, params: { id: product.id }
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'authorization' do
    it 'returns unauthorized for non-supplier' do
      customer = create(:user)
      allow(controller).to receive(:current_user).and_return(customer)
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end
  end
end