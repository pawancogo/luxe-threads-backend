require 'rails_helper'

RSpec.describe Api::V1::ProductBulkOperationsController, type: :controller do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'POST #bulk_upload' do
    it 'uploads products via CSV' do
      csv_content = "name,description,price\nProduct 1,Description 1,100.0"
      csv_file = fixture_file_upload('test.csv', 'text/csv')
      
      allow(ProductBulkImportService).to receive(:new).and_return(
        double(call: double(results: { total: 1, successful: 1, failed: 0, products: [], errors: [] }), success?: true)
      )
      
      post :bulk_upload, params: { csv_file: csv_file }
      
      expect(response).to have_http_status(:ok)
    end

    it 'returns error for invalid file type' do
      file = fixture_file_upload('test.pdf', 'application/pdf')
      
      post :bulk_upload, params: { csv_file: file }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #bulk_delete' do
    it 'deletes multiple products' do
      products = create_list(:product, 3, supplier_profile: supplier_profile)
      product_ids = products.map(&:id)
      
      allow(BulkDeletionService).to receive(:new).and_return(
        double(call: double(success?: true, deleted_count: 3))
      )
      
      post :bulk_delete, params: { product_ids: product_ids }
      
      expect(response).to have_http_status(:ok)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





