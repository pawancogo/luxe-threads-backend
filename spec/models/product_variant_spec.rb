require 'rails_helper'

RSpec.describe ProductVariant, type: :model do
  subject { build(:product_variant) }
  describe 'validations' do
    it { should validate_presence_of(:sku) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:stock_quantity) }
    it { should validate_uniqueness_of(:sku) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should have_many(:product_variant_attributes).dependent(:destroy) }
    it { should have_many(:attribute_values).through(:product_variant_attributes) }
    it { should have_many(:product_images).dependent(:destroy) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:wishlist_items).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      product_variant = build(:product_variant)
      expect(product_variant).to be_valid
    end
  end

  describe 'methods' do
    let(:product_variant) { create(:product_variant) }

    describe '#available?' do
      it 'returns true when stock_quantity is greater than 0' do
        product_variant.stock_quantity = 5
        expect(product_variant.available?).to be true
      end

      it 'returns false when stock_quantity is 0' do
        product_variant.stock_quantity = 0
        expect(product_variant.available?).to be false
      end
    end

    describe '#current_price' do
      it 'returns discounted_price when available' do
        product_variant.discounted_price = 80.0
        product_variant.price = 100.0
        expect(product_variant.current_price).to eq(80.0)
      end

      it 'returns price when discounted_price is nil' do
        product_variant.discounted_price = nil
        product_variant.price = 100.0
        expect(product_variant.current_price).to eq(100.0)
      end
    end
  end
end