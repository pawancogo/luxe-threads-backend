require 'rails_helper'

RSpec.describe SkuGenerationService, type: :service do
  let(:product) { create(:product, name: 'Test Product') }
  let(:product_variant) { create(:product_variant, product: product, sku: nil) }

  describe '.generate_for' do
    it 'generates unique SKU for product variant' do
      sku = SkuGenerationService.generate_for(product_variant)
      
      expect(sku).to be_present
      expect(sku).to include('-')
      expect(product_variant.reload.sku).to eq(sku)
    end

    it 'generates different SKUs for different variants' do
      variant1 = create(:product_variant, product: product)
      variant2 = create(:product_variant, product: product)
      
      sku1 = SkuGenerationService.generate_for(variant1)
      sku2 = SkuGenerationService.generate_for(variant2)
      
      expect(sku1).not_to eq(sku2)
    end

    it 'handles products without names' do
      product.update(name: nil)
      sku = SkuGenerationService.generate_for(product_variant)
      
      expect(sku).to start_with('PROD-')
    end
  end

  describe '#generate' do
    it 'ensures SKU uniqueness' do
      existing_variant = create(:product_variant, sku: 'TEST-ABC123')
      service = SkuGenerationService.new(product_variant)
      
      allow(ProductVariant).to receive(:exists?).and_return(true, false)
      
      sku = service.generate
      expect(sku).to be_present
    end
  end
end

