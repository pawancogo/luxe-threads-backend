require 'rails_helper'

RSpec.describe ReturnItem, type: :model do
  describe 'associations' do
    it { should belong_to(:return_request) }
    it { should belong_to(:order_item) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      return_item = build(:return_item)
      expect(return_item).to be_valid
    end
  end
end