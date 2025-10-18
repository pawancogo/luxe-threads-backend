require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe 'associations' do
    it { should belong_to(:supplier_profile) }
    it { should belong_to(:category) }
    it { should belong_to(:brand) }
    it { should belong_to(:verified_by_admin).class_name('User').optional }
    it { should have_many(:product_variants).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, active: 1, rejected: 2, archived: 3).backed_by_column_of_type(:integer) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      product = build(:product)
      expect(product).to be_valid
    end
  end

  describe 'methods' do
    let(:product) { create(:product) }

    describe '#search_data' do
      it 'returns search data hash' do
        search_data = product.search_data
        expect(search_data).to be_a(Hash)
        expect(search_data[:id]).to eq(product.id)
        expect(search_data[:name]).to eq(product.name)
        expect(search_data[:description]).to eq(product.description)
        expect(search_data[:status]).to eq(product.status)
        expect(search_data[:brand_name]).to eq(product.brand.name)
        expect(search_data[:category_name]).to eq(product.category.name)
        expect(search_data[:supplier_name]).to eq(product.supplier_profile.company_name)
        expect(search_data[:variants]).to be_an(Array)
      end
    end

    describe 'status methods' do
      it 'has pending? method' do
        product.status = 0
        expect(product.pending?).to be true
      end

      it 'has active? method' do
        product.status = 1
        expect(product.active?).to be true
      end

      it 'has rejected? method' do
        product.status = 2
        expect(product.rejected?).to be true
      end

      it 'has archived? method' do
        product.status = 3
        expect(product.archived?).to be true
      end
    end

    describe 'associations with data' do
      it 'can have multiple product variants' do
        variant1 = create(:product_variant, product: product)
        variant2 = create(:product_variant, product: product)
        
        expect(product.product_variants.count).to eq(2)
        expect(product.product_variants).to include(variant1, variant2)
      end

      it 'can have multiple reviews' do
        review1 = create(:review, product: product)
        review2 = create(:review, product: product)
        
        expect(product.reviews.count).to eq(2)
        expect(product.reviews).to include(review1, review2)
      end
    end
  end
end