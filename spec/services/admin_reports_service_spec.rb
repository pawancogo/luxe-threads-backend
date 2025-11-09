require 'rails_helper'

RSpec.describe AdminReportsService, type: :service do
  let(:service) { AdminReportsService.new }

  describe '#sales_report' do
    it 'generates sales report' do
      create_list(:order, 3, status: 'confirmed')
      
      report = service.sales_report
      
      expect(report).to have_key(:summary)
      expect(report).to have_key(:daily_stats)
      expect(report).to have_key(:sales_by_status)
    end

    it 'includes period information' do
      report = service.sales_report
      
      expect(report[:period]).to have_key(:start_date)
      expect(report[:period]).to have_key(:end_date)
    end
  end

  describe '#products_report' do
    it 'generates products report' do
      create_list(:product, 3)
      
      report = service.products_report
      
      expect(report).to have_key(:summary)
      expect(report).to have_key(:products_by_status)
    end
  end

  describe '#users_report' do
    it 'generates users report' do
      create_list(:user, 3)
      
      report = service.users_report
      
      expect(report).to have_key(:summary)
      expect(report).to have_key(:users_by_role)
    end
  end
end

