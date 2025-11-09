require 'rails_helper'

RSpec.describe ProductAttribute, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of(:attribute_value_id).scoped_to(:product_id) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:attribute_value) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      product_attribute = build(:product_attribute)
      expect(product_attribute).to be_valid
    end
  end
end

