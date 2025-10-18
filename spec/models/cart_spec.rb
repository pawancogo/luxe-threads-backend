require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:cart_items).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      cart = build(:cart)
      expect(cart).to be_valid
    end
  end

  describe 'methods' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }
    let(:product_variant) { create(:product_variant, product: product) }

    describe '#total_items' do
      it 'returns 0 for empty cart' do
        expect(cart.total_items).to eq(0)
      end

      it 'returns total quantity of items' do
        create(:cart_item, cart: cart, product_variant: product_variant, quantity: 2)
        create(:cart_item, cart: cart, product_variant: product_variant, quantity: 3)
        expect(cart.total_items).to eq(5)
      end
    end

    describe '#total_amount' do
      it 'returns 0 for empty cart' do
        expect(cart.total_amount).to eq(0)
      end

      it 'calculates total amount based on current prices' do
        product_variant.update(price: 100.0, discounted_price: 80.0)
        create(:cart_item, cart: cart, product_variant: product_variant, quantity: 2)
        expect(cart.total_amount).to eq(160.0) # 2 * 80.0
      end
    end

    describe '#empty?' do
      it 'returns true for empty cart' do
        expect(cart.empty?).to be true
      end

      it 'returns false for cart with items' do
        create(:cart_item, cart: cart, product_variant: product_variant)
        expect(cart.empty?).to be false
      end
    end
  end
end