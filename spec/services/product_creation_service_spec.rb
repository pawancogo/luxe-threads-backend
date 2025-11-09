require 'rails_helper'

RSpec.describe ProductCreationService, type: :service do
  let(:supplier_profile) { create(:supplier_profile) }
  let(:category) { create(:category) }
  let(:brand) { create(:brand) }
  
  let(:valid_params) do
    {
      name: 'Test Product',
      description: 'Test Description',
      category_id: category.id,
      brand_id: brand.id,
      base_price: 100.0,
      product_type: 'physical'
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a product successfully' do
        service = ProductCreationService.new(supplier_profile, valid_params)
        
        expect {
          service.call
        }.to change(Product, :count).by(1)
        
        expect(service.success?).to be true
        expect(service.product).to be_persisted
        expect(service.product.name).to eq('Test Product')
      end

      it 'assigns product to supplier profile' do
        service = ProductCreationService.new(supplier_profile, valid_params)
        service.call
        
        expect(service.product.supplier_profile).to eq(supplier_profile)
      end

      it 'sets default status to pending' do
        service = ProductCreationService.new(supplier_profile, valid_params)
        service.call
        
        expect(service.product.status).to eq('pending')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for missing name' do
        invalid_params = valid_params.except(:name)
        
        service = ProductCreationService.new(supplier_profile, invalid_params)
        service.call
        
        expect(service.success?).to be false
        expect(service.errors).to be_present
      end

      it 'returns errors for missing category' do
        invalid_params = valid_params.except(:category_id)
        
        service = ProductCreationService.new(supplier_profile, invalid_params)
        service.call
        
        expect(service.success?).to be false
      end
    end

    context 'with variants' do
      it 'creates product with variants' do
        params_with_variants = valid_params.merge(
          variants_attributes: [
            { sku: 'SKU-001', price: 100, stock_quantity: 10 }
          ]
        )
        
        service = ProductCreationService.new(supplier_profile, params_with_variants)
        service.call
        
        expect(service.success?).to be true
        expect(service.product.product_variants.count).to eq(1)
      end
    end
  end
end

