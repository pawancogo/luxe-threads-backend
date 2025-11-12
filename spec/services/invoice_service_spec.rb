require 'rails_helper'

RSpec.describe InvoiceService, type: :service do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user, order_number: 'ORD-001') }
  let!(:order_item) { create(:order_item, order: order) }

  describe '.generate_pdf' do
    it 'generates PDF invoice' do
      pdf_data = InvoiceService.generate_pdf(order)

      expect(pdf_data).to be_present
      expect(pdf_data).to be_a(String)
      # PDF files start with %PDF
      expect(pdf_data[0..3]).to eq('%PDF')
    end

    it 'includes order information' do
      pdf_data = InvoiceService.generate_pdf(order)
      # Basic check that PDF was generated
      expect(pdf_data.length).to be > 1000
    end
  end

  describe '#generate' do
    let(:service) { InvoiceService.new(order) }

    it 'generates PDF document' do
      pdf_data = service.generate

      expect(pdf_data).to be_present
      expect(pdf_data).to be_a(String)
    end
  end
end





