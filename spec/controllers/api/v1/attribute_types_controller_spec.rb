require 'rails_helper'

RSpec.describe Api::V1::AttributeTypesController, type: :controller do
  describe 'GET #index' do
    it 'returns all attribute types' do
      create_list(:attribute_type, 3)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns attribute type details' do
      attribute_type = create(:attribute_type)
      get :show, params: { id: attribute_type.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(attribute_type.id)
    end
  end
end
