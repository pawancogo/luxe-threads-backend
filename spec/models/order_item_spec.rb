require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product_variant) }
    it { should have_many(:return_items).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      order_item = build(:order_item)
      expect(order_item).to be_valid
    end
  end
end