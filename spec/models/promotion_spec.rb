require 'rails_helper'

RSpec.describe Promotion, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:promotion_type) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
  end

  describe 'associations' do
    it { should belong_to(:created_by).class_name('Admin').optional }
  end

  describe 'enums' do
    it { should define_enum_for(:promotion_type).with_values(
      flash_sale: 'flash_sale',
      buy_x_get_y: 'buy_x_get_y',
      bundle_deal: 'bundle_deal',
      seasonal_sale: 'seasonal_sale'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active promotions' do
        active = create(:promotion, is_active: true, start_date: 1.day.ago, end_date: 1.day.from_now)
        expired = create(:promotion, is_active: true, start_date: 2.days.ago, end_date: 1.day.ago)
        
        expect(Promotion.active).to include(active)
        expect(Promotion.active).not_to include(expired)
      end
    end
  end

  describe 'instance methods' do
    let(:promotion) { create(:promotion) }

    describe '#current?' do
      it 'returns true for current promotion' do
        promotion.update(is_active: true, start_date: 1.day.ago, end_date: 1.day.from_now)
        expect(promotion.current?).to be true
      end
    end
  end
end





