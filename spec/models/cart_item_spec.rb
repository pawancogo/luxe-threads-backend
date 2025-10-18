require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product_variant) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      cart_item = build(:cart_item)
      expect(cart_item).to be_valid
    end
  end
end