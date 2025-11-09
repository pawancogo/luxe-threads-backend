require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:transaction_id) }
    it { should validate_uniqueness_of(:transaction_id) }
  end

  describe 'associations' do
    it { should belong_to(:payment) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      payment_transaction = build(:payment_transaction)
      expect(payment_transaction).to be_valid
    end
  end
end

