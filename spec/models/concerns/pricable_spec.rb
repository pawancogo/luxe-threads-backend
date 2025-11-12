require 'rails_helper'

RSpec.describe Pricable, type: :concern do
  let(:test_model) do
    product_variant = create(:product_variant, price: 1000, discounted_price: 800, currency: 'INR')
    product_variant.extend(Pricable)
    product_variant
  end

  describe '#price_object' do
    it 'returns Price value object' do
      price = test_model.price_object
      expect(price).to be_a(Price)
      expect(price.base).to eq(1000)
      expect(price.discounted_price).to eq(800)
    end
  end

  describe '#current_price' do
    it 'returns discounted price when available' do
      expect(test_model.current_price).to eq(800)
    end

    it 'returns base price when no discount' do
      test_model.update(discounted_price: nil)
      expect(test_model.current_price).to eq(1000)
    end
  end

  describe '#discounted?' do
    it 'returns true when discounted' do
      expect(test_model.discounted?).to be true
    end

    it 'returns false when not discounted' do
      test_model.update(discounted_price: nil)
      expect(test_model.discounted?).to be false
    end
  end

  describe '#discount_amount' do
    it 'returns discount amount' do
      expect(test_model.discount_amount).to eq(200)
    end
  end

  describe '#discount_percentage' do
    it 'returns discount percentage' do
      expect(test_model.discount_percentage).to eq(20.0)
    end
  end

  describe '#formatted_price' do
    it 'returns formatted price string' do
      formatted = test_model.formatted_price
      expect(formatted).to be_a(String)
      expect(formatted).to include('800')
    end
  end
end





