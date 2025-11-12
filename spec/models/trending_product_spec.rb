require 'rails_helper'

RSpec.describe TrendingProduct, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of(:product_id).scoped_to(:calculated_at) }
    it { should validate_numericality_of(:trend_score).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:category).optional }
  end

  describe 'scopes' do
    describe '.today' do
      it 'returns today trending products' do
        today = create(:trending_product, calculated_at: Time.current)
        yesterday = create(:trending_product, calculated_at: 1.day.ago)
        expect(TrendingProduct.today).to include(today)
        expect(TrendingProduct.today).not_to include(yesterday)
      end
    end

    describe '.top_trending' do
      it 'orders by trend_score desc' do
        low = create(:trending_product, trend_score: 10)
        high = create(:trending_product, trend_score: 100)
        expect(TrendingProduct.top_trending.first).to eq(high)
      end
    end
  end

  describe 'callbacks' do
    it 'calculates trend score before save' do
      product = create(:product)
      trending = build(:trending_product, product: product, views_24h: 100, orders_24h: 10, revenue_24h: 500)
      trending.save!
      expect(trending.trend_score).to be > 0
    end
  end
end





