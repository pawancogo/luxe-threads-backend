require 'rails_helper'

RSpec.describe ProductVariantAttribute, type: :model do
  describe 'associations' do
    it { should belong_to(:product_variant) }
    it { should belong_to(:attribute_value) }
    it { should belong_to(:attribute_type) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:product_variant_id).scoped_to(:attribute_value_id) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:product_variant_attribute)).to be_valid
    end
  end
end
