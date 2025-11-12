require 'rails_helper'

RSpec.describe Api::V1::SupplierDocumentsController, type: :controller do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns supplier documents' do
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'POST #upload' do
    it 'uploads document' do
      post :upload, params: {
        document_type: 'gst_certificate',
        file: fixture_file_upload('test.pdf', 'application/pdf')
      }
      
      expect(response).to have_http_status(:created)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





