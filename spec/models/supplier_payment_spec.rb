require 'rails_helper'

RSpec.describe SupplierPayment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:net_amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:payment_method) }
    it { should validate_presence_of(:period_start_date) }
    it { should validate_presence_of(:period_end_date) }
    it { should validate_uniqueness_of(:payment_id) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_numericality_of(:net_amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:supplier_profile) }
    it { should belong_to(:processed_by).class_name('Admin').optional }
  end

  describe 'enums' do
    it { should define_enum_for(:payment_method).with_values(
      bank_transfer: 'bank_transfer',
      upi: 'upi',
      neft: 'neft',
      rtgs: 'rtgs'
    ).backed_by_column_of_type(:string) }

    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
      cancelled: 'cancelled'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    it 'generates payment_id before validation' do
      payment = build(:supplier_payment, payment_id: nil)
      payment.valid?
      expect(payment.payment_id).to be_present
      expect(payment.payment_id).to start_with('SUP-')
    end

    it 'calculates net_amount before validation' do
      payment = build(:supplier_payment, amount: 1000, commission_deducted: 100)
      payment.valid?
      expect(payment.net_amount).to eq(900)
    end
  end

  describe 'instance methods' do
    let(:supplier_profile) { create(:supplier_profile) }
    let(:payment) { create(:supplier_payment, supplier_profile: supplier_profile, amount: 1000, commission_deducted: 100) }

    describe '#commission_rate' do
      it 'calculates commission rate' do
        expect(payment.commission_rate).to eq(10.0)
      end
    end
  end
end

