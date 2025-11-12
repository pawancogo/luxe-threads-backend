require 'rails_helper'

RSpec.describe SupplierAnalyticsService, type: :service do
  let(:supplier_profile) { create(:supplier_profile) }
  let(:service) { SupplierAnalyticsService.new(supplier_profile) }

  describe '#call' do
    context 'with orders' do
      let(:order) { create(:order, status: 'confirmed') }
      let!(:order_item) do
        create(:order_item,
               order: order,
               supplier_profile: supplier_profile,
               fulfillment_status: 'delivered',
               final_price: 100.0,
               quantity: 2)
      end

      it 'calculates summary statistics' do
        result = service.call

        expect(result).to have_key(:summary)
        expect(result[:summary]).to have_key(:total_revenue)
        expect(result[:summary]).to have_key(:total_orders)
        expect(result[:summary]).to have_key(:total_items_sold)
      end

      it 'calculates daily stats' do
        result = service.call

        expect(result).to have_key(:daily_stats)
        expect(result[:daily_stats]).to be_an(Array)
      end

      it 'calculates top products' do
        result = service.call

        expect(result).to have_key(:top_products)
      end

      it 'calculates sales by status' do
        result = service.call

        expect(result).to have_key(:sales_by_status)
      end
    end

    context 'with date range' do
      it 'filters by date range' do
        service = SupplierAnalyticsService.new(
          supplier_profile,
          start_date: 7.days.ago.to_date,
          end_date: Date.current
        )

        result = service.call

        expect(result[:period][:start_date]).to be_present
        expect(result[:period][:end_date]).to be_present
      end
    end

    context 'with no orders' do
      it 'returns empty summary' do
        result = service.call

        expect(result[:summary][:total_revenue]).to eq(0.0)
        expect(result[:summary][:total_orders]).to eq(0)
      end
    end
  end
end





