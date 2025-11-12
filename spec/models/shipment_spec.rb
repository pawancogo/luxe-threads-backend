require 'rails_helper'

RSpec.describe Shipment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:from_address) }
    it { should validate_presence_of(:to_address) }
    it { should validate_uniqueness_of(:shipment_id) }
  end

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:order_item).optional }
    it { should belong_to(:shipping_method).optional }
    it { should have_many(:shipment_tracking_events).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      label_created: 'label_created',
      picked_up: 'picked_up',
      in_transit: 'in_transit',
      out_for_delivery: 'out_for_delivery',
      delivered: 'delivered',
      failed: 'failed',
      returned: 'returned'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    it 'generates shipment_id before validation' do
      shipment = build(:shipment, shipment_id: nil)
      shipment.valid?
      expect(shipment.shipment_id).to be_present
      expect(shipment.shipment_id).to start_with('SHIP-')
    end

    it 'updates status_updated_at when status changes' do
      shipment = create(:shipment, status: 'pending')
      expect { shipment.update(status: 'in_transit') }.to change { shipment.status_updated_at }
    end
  end

  describe 'instance methods' do
    let(:shipment) { create(:shipment) }

    describe '#from_address_data' do
      it 'returns parsed from address' do
        shipment.update(from_address: '{"city": "Mumbai"}')
        expect(shipment.from_address_data).to eq({ 'city' => 'Mumbai' })
      end
    end

    describe '#to_address_data' do
      it 'returns parsed to address' do
        shipment.update(to_address: '{"city": "Delhi"}')
        expect(shipment.to_address_data).to eq({ 'city' => 'Delhi' })
      end
    end
  end
end





