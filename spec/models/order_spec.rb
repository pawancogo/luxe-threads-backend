require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:shipping_address).class_name('Address') }
    it { should belong_to(:billing_address).class_name('Address') }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:return_requests).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      order = build(:order)
      expect(order).to be_valid
    end
  end

  describe 'methods' do
    let(:order) { create(:order) }

    describe 'status methods' do
      it 'has pending? method' do
        order.status = 'pending'
        expect(order.pending?).to be true
      end

      it 'has paid? method' do
        order.status = 'paid'
        expect(order.paid?).to be true
      end

      it 'has packed? method' do
        order.status = 'packed'
        expect(order.packed?).to be true
      end

      it 'has shipped? method' do
        order.status = 'shipped'
        expect(order.shipped?).to be true
      end

      it 'has delivered? method' do
        order.status = 'delivered'
        expect(order.delivered?).to be true
      end

      it 'has cancelled? method' do
        order.status = 'cancelled'
        expect(order.cancelled?).to be true
      end
    end

    describe 'payment_status methods' do
      it 'has payment_pending? method' do
        order.payment_status = 'payment_pending'
        expect(order.payment_pending?).to be true
      end

      it 'has payment_complete? method' do
        order.payment_status = 'payment_complete'
        expect(order.payment_complete?).to be true
      end

      it 'has payment_failed? method' do
        order.payment_status = 'payment_failed'
        expect(order.payment_failed?).to be true
      end
    end

    describe 'associations with data' do
      it 'can have multiple order items' do
        item1 = create(:order_item, order: order)
        item2 = create(:order_item, order: order)
        
        expect(order.order_items.count).to eq(2)
        expect(order.order_items).to include(item1, item2)
      end

      it 'can have multiple return requests' do
        return1 = create(:return_request, order: order)
        return2 = create(:return_request, order: order)
        
        expect(order.return_requests.count).to eq(2)
        expect(order.return_requests).to include(return1, return2)
      end
    end
  end
end