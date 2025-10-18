require 'rails_helper'

RSpec.describe Wishlist, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:wishlist_items).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      wishlist = build(:wishlist)
      expect(wishlist).to be_valid
    end
  end
end