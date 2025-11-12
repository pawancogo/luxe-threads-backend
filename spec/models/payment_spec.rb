require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:payment_method) }
    it { should validate_uniqueness_of(:payment_id) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:user) }
    it { should have_many(:payment_refunds).dependent(:destroy) }
    it { should have_many(:payment_transactions).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:payment_method).with_values(
      cod: 'cod',
      credit_card: 'credit_card',
      debit_card: 'debit_card',
      upi: 'upi',
      wallet: 'wallet',
      netbanking: 'netbanking',
      emi: 'emi'
    ).backed_by_column_of_type(:string) }

    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
      refunded: 'refunded',
      partially_refunded: 'partially_refunded'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    it 'generates payment_id before validation' do
      payment = build(:payment, payment_id: nil)
      payment.valid?
      expect(payment.payment_id).to be_present
      expect(payment.payment_id).to start_with('PAY-')
    end
  end

  describe 'instance methods' do
    let(:payment) { create(:payment) }

    describe '#gateway_response_data' do
      it 'returns parsed gateway response' do
        payment.update(gateway_response: '{"status": "success"}')
        expect(payment.gateway_response_data).to eq({ 'status' => 'success' })
      end

      it 'returns empty hash for blank response' do
        payment.update(gateway_response: nil)
        expect(payment.gateway_response_data).to eq({})
      end
    end
  end
end





