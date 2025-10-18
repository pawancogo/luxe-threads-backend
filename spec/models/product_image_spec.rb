require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:image_url) }
    it { should validate_presence_of(:display_order) }
    it { should validate_numericality_of(:display_order).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:product_variant) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      product_image = build(:product_image)
      expect(product_image).to be_valid
    end
  end
end