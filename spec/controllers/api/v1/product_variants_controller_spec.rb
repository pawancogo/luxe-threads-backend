require 'rails_helper'

RSpec.describe Api::V1::ProductVariantsController, type: :controller do
  let(:supplier) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier) }
  let(:product) { create(:product, supplier_profile: supplier_profile) }
  let(:valid_params) do
    {
      product_id: product.id,
      product_variant: {
        sku: 'TEST-SKU-001',
        price: 100.0,
        stock_quantity: 10,
        weight_kg: 1.5
      }
    }
  end

  before do
    allow(controller).to receive(:current_user).and_return(supplier)
    allow(controller).to receive(:authenticate_request)
    # Ensure supplier has a supplier_profile
    supplier.supplier_profile = supplier_profile
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::ProductVariantsController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authorize_supplier! before_action' do
      expect(Api::V1::ProductVariantsController._process_action_callbacks.map(&:filter)).to include(:authorize_supplier!)
    end

    it 'has set_product before_action' do
      expect(Api::V1::ProductVariantsController._process_action_callbacks.map(&:filter)).to include(:set_product)
    end
  end

  describe 'POST #create' do
    it 'creates product variant with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('sku')
    end

    it 'returns error with invalid params' do
      invalid_params = valid_params.merge(product_variant: { sku: '', price: -1 })
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('sku')
    end

    it 'returns unauthorized for non-supplier' do
      customer = create(:user)
      allow(controller).to receive(:current_user).and_return(customer)
      post :create, params: valid_params
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to have_key('error')
    end

    it 'raises exception for non-existent product' do
      invalid_params = valid_params.merge(product_id: 999)
      expect { post :create, params: invalid_params }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
