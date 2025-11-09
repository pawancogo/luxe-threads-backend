require 'rails_helper'

RSpec.describe ReviewHelpfulVote, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of(:user_id).scoped_to(:review_id) }
  end

  describe 'associations' do
    it { should belong_to(:review) }
    it { should belong_to(:user) }
  end

  describe 'callbacks' do
    it 'updates review counts after save' do
      review = create(:review)
      expect(review).to receive(:update_helpful_counts)
      create(:review_helpful_vote, review: review)
    end

    it 'updates review counts after destroy' do
      vote = create(:review_helpful_vote)
      expect(vote.review).to receive(:update_helpful_counts)
      vote.destroy
    end
  end
end

