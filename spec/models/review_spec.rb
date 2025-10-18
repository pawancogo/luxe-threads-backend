require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:product) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      review = build(:review)
      expect(review).to be_valid
    end
  end
end