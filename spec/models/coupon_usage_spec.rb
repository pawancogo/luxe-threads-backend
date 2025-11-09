require 'rails_helper'

RSpec.describe CouponUsage, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:coupon_id) }
    it { should validate_presence_of(:order_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:coupon) }
    it { should belong_to(:order) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      usage = build(:coupon_usage)
      expect(usage).to be_valid
    end
  end
end

