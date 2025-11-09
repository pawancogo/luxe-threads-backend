require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:order_number) }
    it { should validate_uniqueness_of(:order_number) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:shipping_address).class_name('Address').optional }
    it { should belong_to(:billing_address).class_name('Address').optional }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:shipments).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', confirmed: 'confirmed', processing: 'processing', shipped: 'shipped', delivered: 'delivered', cancelled: 'cancelled', returned: 'returned') }
    it { should define_enum_for(:payment_status).with_values(pending: 'pending', paid: 'paid', failed: 'failed', refunded: 'refunded') }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:order)).to be_valid
    end
  end

  describe '#can_cancel?' do
    it 'returns true for cancellable orders' do
      order = create(:order, status: 'pending')
      expect(order.can_cancel?).to be true
    end

    it 'returns false for non-cancellable orders' do
      order = create(:order, status: 'delivered')
      expect(order.can_cancel?).to be false
    end
  end
end