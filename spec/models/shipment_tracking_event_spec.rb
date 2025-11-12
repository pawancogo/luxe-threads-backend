require 'rails_helper'

RSpec.describe ShipmentTrackingEvent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:event_time) }
  end

  describe 'associations' do
    it { should belong_to(:shipment) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      event = build(:shipment_tracking_event)
      expect(event).to be_valid
    end
  end
end





