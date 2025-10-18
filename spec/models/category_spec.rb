require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      category = build(:category)
      expect(category).to be_valid
    end
  end
end
