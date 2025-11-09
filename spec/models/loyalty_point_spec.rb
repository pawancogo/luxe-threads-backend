require 'rails_helper'

RSpec.describe LoyaltyPoint, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:loyalty_points_transactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:points_balance) }
    it { should validate_numericality_of(:points_balance).is_greater_than_or_equal_to(0) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:loyalty_point)).to be_valid
    end
  end

  describe '#add_points' do
    it 'adds points to balance' do
      loyalty_point = create(:loyalty_point, points_balance: 100)
      loyalty_point.add_points(50)
      expect(loyalty_point.points_balance).to eq(150)
    end
  end

  describe '#deduct_points' do
    it 'deducts points from balance' do
      loyalty_point = create(:loyalty_point, points_balance: 100)
      loyalty_point.deduct_points(30)
      expect(loyalty_point.points_balance).to eq(70)
    end
  end
end

