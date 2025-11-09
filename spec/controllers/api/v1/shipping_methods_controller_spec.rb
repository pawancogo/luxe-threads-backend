require 'rails_helper'

RSpec.describe Api::V1::ShippingMethodsController, type: :controller do
  describe 'GET #index' do
    it 'returns all shipping methods' do
      create_list(:shipping_method, 3)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'filters active shipping methods' do
      active = create(:shipping_method, active: true)
      inactive = create(:shipping_method, active: false)
      
      get :index, params: { active: 'true' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].map { |s| s['id'] }).to include(active.id)
      expect(json_response['data'].map { |s| s['id'] }).not_to include(inactive.id)
    end
  end

  describe 'GET #show' do
    it 'returns shipping method details' do
      shipping_method = create(:shipping_method)
      get :show, params: { id: shipping_method.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(shipping_method.id)
    end
  end
end
