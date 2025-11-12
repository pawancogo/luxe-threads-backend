require 'rails_helper'

RSpec.describe SupplierAnalytic, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_uniqueness_of(:date).scoped_to(:supplier_profile_id) }
    it { should validate_numericality_of(:total_orders).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_revenue).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:conversion_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'associations' do
    it { should belong_to(:supplier_profile) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'orders by date desc' do
        old = create(:supplier_analytic, date: 2.days.ago)
        recent = create(:supplier_analytic, date: Date.current)
        expect(SupplierAnalytic.recent.first).to eq(recent)
      end
    end
  end

  describe 'callbacks' do
    it 'calculates conversion rate before save' do
      analytic = build(:supplier_analytic, products_viewed: 100, products_added_to_cart: 25)
      analytic.save!
      expect(analytic.conversion_rate).to eq(25.0)
    end
  end
end





