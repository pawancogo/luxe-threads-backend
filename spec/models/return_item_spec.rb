require 'rails_helper'

RSpec.describe ReturnItem, type: :model do
  describe 'associations' do
    it { should belong_to(:return_request) }
    it { should belong_to(:order_item) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:return_item)).to be_valid
    end
  end
end
