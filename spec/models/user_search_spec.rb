require 'rails_helper'

RSpec.describe UserSearch, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:query) }
  end

  describe 'scopes' do
    it 'filters by user' do
      user = create(:user)
      search1 = create(:user_search, user: user)
      search2 = create(:user_search, user: nil)
      
      expect(UserSearch.by_user(user.id)).to include(search1)
      expect(UserSearch.by_user(user.id)).not_to include(search2)
    end

    it 'filters recent searches' do
      old_search = create(:user_search, created_at: 2.days.ago)
      recent_search = create(:user_search, created_at: 1.hour.ago)
      
      expect(UserSearch.recent).to include(recent_search)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user_search)).to be_valid
    end
  end
end
