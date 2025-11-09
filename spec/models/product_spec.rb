require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:supplier_profile).optional }
    it { should belong_to(:category).optional }
    it { should belong_to(:brand).optional }
    it { should have_many(:product_variants).dependent(:destroy) }
    it { should have_many(:product_images).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(draft: 'draft', pending: 'pending', active: 'active', inactive: 'inactive', rejected: 'rejected') }
  end

  describe 'scopes' do
    it 'filters active products' do
      active = create(:product, status: 'active')
      inactive = create(:product, status: 'inactive')
      
      expect(Product.active).to include(active)
      expect(Product.active).not_to include(inactive)
    end

    it 'filters featured products' do
      featured = create(:product, is_featured: true)
      regular = create(:product, is_featured: false)
      
      expect(Product.featured).to include(featured)
      expect(Product.featured).not_to include(regular)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:product)).to be_valid
    end
  end

  describe '#average_rating' do
    it 'calculates average rating from reviews' do
      product = create(:product)
      create(:review, product: product, rating: 5)
      create(:review, product: product, rating: 3)
      
      expect(product.average_rating).to eq(4.0)
    end
  end
end
