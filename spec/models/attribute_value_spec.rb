require 'rails_helper'

RSpec.describe AttributeValue, type: :model do
  describe 'validations' do
    # No validations defined in the model
  end

  describe 'associations' do
    it { should belong_to(:attribute_type) }
    it { should have_many(:product_variant_attributes).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      attribute_value = build(:attribute_value)
      expect(attribute_value).to be_valid
    end
  end
end
