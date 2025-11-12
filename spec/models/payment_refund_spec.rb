require 'rails_helper'

RSpec.describe PaymentRefund, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:reason) }
    it { should validate_uniqueness_of(:refund_id) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:payment) }
    it { should belong_to(:order) }
    it { should belong_to(:order_item).optional }
    it { should belong_to(:processed_by).class_name('User').optional }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
      cancelled: 'cancelled'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    it 'generates refund_id before validation' do
      refund = build(:payment_refund, refund_id: nil)
      refund.valid?
      expect(refund.refund_id).to be_present
      expect(refund.refund_id).to start_with('REF-')
    end
  end

  describe 'instance methods' do
    let(:refund) { create(:payment_refund) }

    describe '#gateway_response_data' do
      it 'returns parsed gateway response' do
        refund.update(gateway_response: '{"status": "success"}')
        expect(refund.gateway_response_data).to eq({ 'status' => 'success' })
      end
    end
  end
end





