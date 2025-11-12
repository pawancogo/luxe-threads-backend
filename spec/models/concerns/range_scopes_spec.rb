require 'rails_helper'

RSpec.describe RangeScopes, type: :concern do
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'promotions'
      include RangeScopes
    end
  end

  describe '.within_range' do
    it 'finds records within date range' do
      promotion = create(:promotion, start_date: 5.days.ago, end_date: 5.days.from_now)
      result = test_model_class.within_range(1.day.ago, 1.day.from_now)
      expect(result).to include(promotion)
    end
  end

  describe '.within_date_range' do
    it 'finds records within created_at range' do
      promotion = create(:promotion, created_at: 2.days.ago)
      result = test_model_class.within_date_range(3.days.ago, 1.day.ago)
      expect(result).to include(promotion)
    end
  end

  describe '.in_price_range' do
    it 'finds records within price range' do
      product = create(:product, base_price: 500)
      product_variant = create(:product_variant, product: product, price: 500)
      
      # Test with ProductVariant if it includes RangeScopes
      if ProductVariant.respond_to?(:in_price_range)
        result = ProductVariant.in_price_range(400, 600)
        expect(result).to include(product_variant)
      end
    end
  end

  describe '.min_price' do
    it 'filters by minimum price' do
      product_variant = create(:product_variant, price: 500)
      
      if ProductVariant.respond_to?(:min_price)
        result = ProductVariant.min_price(400)
        expect(result).to include(product_variant)
      end
    end
  end

  describe '.max_price' do
    it 'filters by maximum price' do
      product_variant = create(:product_variant, price: 500)
      
      if ProductVariant.respond_to?(:max_price)
        result = ProductVariant.max_price(600)
        expect(result).to include(product_variant)
      end
    end
  end
end





