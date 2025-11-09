require 'rails_helper'

RSpec.describe ProductBulkImportService, type: :service do
  let(:supplier_profile) { create(:supplier_profile) }
  let(:csv_content) do
    "name,description,price,stock_quantity\nProduct 1,Description 1,100,10\nProduct 2,Description 2,200,20"
  end

  describe '#call' do
    it 'imports products from CSV' do
      service = ProductBulkImportService.new(supplier_profile, csv_content)
      
      service.call
      
      expect(service.results[:total]).to eq(2)
    end

    it 'returns errors for invalid CSV' do
      service = ProductBulkImportService.new(supplier_profile, 'invalid csv')
      
      service.call
      
      expect(service.errors).not_to be_empty
    end

    it 'returns errors for blank CSV' do
      service = ProductBulkImportService.new(supplier_profile, '')
      
      service.call
      
      expect(service.errors).to include('CSV content is required')
    end
  end

  describe '#success?' do
    it 'returns true when import succeeds' do
      service = ProductBulkImportService.new(supplier_profile, csv_content)
      service.call
      
      # Mock successful import
      allow(service).to receive(:results).and_return({ failed: 0 })
      allow(service).to receive(:errors).and_return([])
      
      expect(service.success?).to be true
    end
  end
end

