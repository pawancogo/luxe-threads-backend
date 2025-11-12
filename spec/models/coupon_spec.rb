require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:coupon_type) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_presence_of(:valid_from) }
    it { should validate_presence_of(:valid_until) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_numericality_of(:discount_value).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:created_by).class_name('Admin').optional }
    it { should have_many(:coupon_usages).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:coupon_type).with_values(
      percentage: 'percentage',
      fixed_amount: 'fixed_amount',
      free_shipping: 'free_shipping',
      buy_one_get_one: 'buy_one_get_one'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active coupons within validity period' do
        active_coupon = create(:coupon, is_active: true, valid_from: 1.day.ago, valid_until: 1.day.from_now)
        expired_coupon = create(:coupon, is_active: true, valid_from: 2.days.ago, valid_until: 1.day.ago)
        
        expect(Coupon.active).to include(active_coupon)
        expect(Coupon.active).not_to include(expired_coupon)
      end
    end

    describe '.available' do
      it 'returns available coupons' do
        available = create(:coupon, is_active: true, max_uses: 10, current_uses: 5)
        exhausted = create(:coupon, is_active: true, max_uses: 10, current_uses: 10)
        
        expect(Coupon.available).to include(available)
        expect(Coupon.available).not_to include(exhausted)
      end
    end
  end

  describe 'instance methods' do
    let(:coupon) { create(:coupon, coupon_type: 'percentage', discount_value: 10) }
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }

    describe '#available?' do
      it 'returns true for available coupon' do
        coupon.update(is_active: true, valid_from: 1.day.ago, valid_until: 1.day.from_now, max_uses: 10, current_uses: 5)
        expect(coupon.available?).to be true
      end

      it 'returns false for inactive coupon' do
        coupon.update(is_active: false)
        expect(coupon.available?).to be false
      end
    end

    describe '#valid_for_user?' do
      it 'returns true for valid user' do
        coupon.update(is_active: true, valid_from: 1.day.ago, valid_until: 1.day.from_now)
        expect(coupon.valid_for_user?(user)).to be true
      end
    end

    describe '#calculate_discount' do
      it 'calculates percentage discount' do
        coupon.update(coupon_type: 'percentage', discount_value: 10)
        expect(coupon.calculate_discount(100)).to eq(10.0)
      end

      it 'calculates fixed amount discount' do
        coupon.update(coupon_type: 'fixed_amount', discount_value: 50)
        expect(coupon.calculate_discount(100)).to eq(50.0)
      end
    end
  end
end





