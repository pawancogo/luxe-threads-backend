require 'rails_helper'

RSpec.describe WishlistItem, type: :model do
  describe 'associations' do
    it { should belong_to(:wishlist) }
    it { should belong_to(:product_variant) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      wishlist_item = build(:wishlist_item)
      expect(wishlist_item).to be_valid
    end
  end
end