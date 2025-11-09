require 'rails_helper'

RSpec.describe AttributeValue, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:value) }
  end

  describe 'associations' do
    it { should belong_to(:attribute_type) }
    it { should have_many(:product_variant_attributes).dependent(:destroy) }
    it { should have_many(:product_variants).through(:product_variant_attributes) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:attribute_value)).to be_valid
    end
  end
end
