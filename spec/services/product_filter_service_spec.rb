require 'rails_helper'

RSpec.describe ProductFilterService, type: :service do
  let!(:product1) { create(:product, name: 'Product 1', status: 'active') }
  let!(:product2) { create(:product, name: 'Product 2', status: 'active') }
  let(:service) { ProductFilterService.new }

  describe '#apply' do
    it 'filters by category' do
      category = create(:category)
      product1.update(category: category)
      
      result = service.apply(category_id: category.id)
      
      expect(result.products).to include(product1)
      expect(result.products).not_to include(product2)
    end

    it 'filters by brand' do
      brand = create(:brand)
      product1.update(brand: brand)
      
      result = service.apply(brand_id: brand.id)
      
      expect(result.products).to include(product1)
    end

    it 'filters by price range' do
      variant1 = create(:product_variant, product: product1, price: 100.0)
      variant2 = create(:product_variant, product: product2, price: 500.0)
      
      result = service.apply(min_price: 50, max_price: 200)
      
      expect(result.products).to include(product1)
      expect(result.products).not_to include(product2)
    end

    it 'filters by featured products' do
      product1.update(is_featured: true)
      
      result = service.apply(featured: true)
      
      expect(result.products).to include(product1)
    end
  end

  describe '#results' do
    it 'returns paginated results' do
      result = service.apply({}).results(page: 1, per_page: 1)
      
      expect(result[:products].count).to eq(1)
      expect(result[:total_count]).to eq(2)
      expect(result[:current_page]).to eq(1)
    end
  end
end

