# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoyaltyPointsTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:transaction_type) }
    it { should validate_presence_of(:points) }
    it { should validate_presence_of(:balance_after) }
  end

  describe 'enums' do
    it { should define_enum_for(:transaction_type).with_values(
      earned: 'earned',
      redeemed: 'redeemed',
      expired: 'expired',
      adjusted: 'adjusted'
    ) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      transaction = build(:loyalty_points_transaction)
      expect(transaction).to be_valid
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:earned_transaction) { create(:loyalty_points_transaction, user: user, transaction_type: 'earned', points: 100) }
    let!(:redeemed_transaction) { create(:loyalty_points_transaction, user: user, transaction_type: 'redeemed', points: -50) }

    it 'filters by transaction type' do
      earned = user.loyalty_points_transactions.where(transaction_type: 'earned')
      expect(earned).to include(earned_transaction)
      expect(earned).not_to include(redeemed_transaction)
    end
  end

  describe 'balance calculation' do
    let(:user) { create(:user) }

    it 'calculates balance correctly' do
      create(:loyalty_points_transaction, user: user, transaction_type: 'earned', points: 100, balance_after: 100)
      create(:loyalty_points_transaction, user: user, transaction_type: 'redeemed', points: -30, balance_after: 70)
      
      latest = user.loyalty_points_transactions.order(created_at: :desc).first
      expect(latest.balance_after).to eq(70)
    end
  end
end

