require 'rails_helper'

RSpec.describe Api::V1::Admin::ReportsController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #sales_report' do
    it 'generates sales report' do
      create_list(:order, 3, status: 'confirmed')
      
      get :sales_report
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data']).to have_key('summary')
    end

    it 'filters by date range' do
      get :sales_report, params: {
        start_date: 7.days.ago.to_date.iso8601,
        end_date: Date.current.iso8601
      }
      
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #products_report' do
    it 'generates products report' do
      create_list(:product, 3)
      
      get :products_report
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'GET #users_report' do
    it 'generates users report' do
      create_list(:user, 3)
      
      get :users_report
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

