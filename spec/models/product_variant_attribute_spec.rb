require 'rails_helper'

RSpec.describe ProductVariantAttribute, type: :model do
  describe 'associations' do
    it { should belong_to(:product_variant) }
    it { should belong_to(:attribute_value) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      product_variant_attribute = build(:product_variant_attribute)
      expect(product_variant_attribute).to be_valid
    end
  end
end
