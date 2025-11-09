require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:product_variants).through(:cart_items) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cart)).to be_valid
    end
  end

  describe '#total' do
    it 'calculates total from cart items' do
      cart = create(:cart)
      variant1 = create(:product_variant, price: 100)
      variant2 = create(:product_variant, price: 200)
      
      create(:cart_item, cart: cart, product_variant: variant1, quantity: 2)
      create(:cart_item, cart: cart, product_variant: variant2, quantity: 1)
      
      expect(cart.total).to eq(400.0)
    end
  end

  describe '#item_count' do
    it 'returns total quantity of items' do
      cart = create(:cart)
      create(:cart_item, cart: cart, quantity: 2)
      create(:cart_item, cart: cart, quantity: 3)
      
      expect(cart.item_count).to eq(5)
    end
  end
end
