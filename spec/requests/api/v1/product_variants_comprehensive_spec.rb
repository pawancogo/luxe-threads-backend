require 'rails_helper'

RSpec.describe 'API V1 Product Variants Comprehensive', type: :request do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:product) { create(:product, supplier_profile: supplier_profile) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
  
  describe 'POST /api/v1/products/:product_id/product_variants' do
    let(:attribute_type) { create(:attribute_type, name: 'Color') }
    let(:attribute_value) { create(:attribute_value, attribute_type: attribute_type, value: 'Red') }
    
    let(:valid_params) do
      {
        product_variant: {
          sku: 'SKU-001',
          price: 100.0,
          discounted_price: 90.0,
          stock_quantity: 50,
          weight_kg: 0.5,
          attribute_value_ids: [attribute_value.id],
          image_urls: ['https://example.com/image1.jpg']
        }
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new product variant' do
        expect {
          post "/api/v1/products/#{product.id}/product_variants", 
               params: valid_params, 
               headers: auth_headers
        }.to change(ProductVariant, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['sku']).to eq('SKU-001')
      end
      
      it 'associates variant with product' do
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        json_response = JSON.parse(response.body)
        variant_id = json_response['data']['id']
        variant = ProductVariant.find(variant_id)
        expect(variant.product).to eq(product)
      end
      
      it 'creates variant attributes' do
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        json_response = JSON.parse(response.body)
        variant_id = json_response['data']['id']
        variant = ProductVariant.find(variant_id)
        expect(variant.product_variant_attributes.count).to eq(1)
        expect(variant.product_variant_attributes.first.attribute_value).to eq(attribute_value)
      end
      
      it 'creates product images' do
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        json_response = JSON.parse(response.body)
        variant_id = json_response['data']['id']
        variant = ProductVariant.find(variant_id)
        expect(variant.product_images.count).to eq(1)
      end
      
      it 'calculates available quantity correctly' do
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        json_response = JSON.parse(response.body)
        variant_id = json_response['data']['id']
        variant = ProductVariant.find(variant_id)
        expect(variant.available_quantity).to eq(50)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors for missing SKU' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product_variant][:sku] = nil
        
        post "/api/v1/products/#{product.id}/product_variants", 
             params: invalid_params, 
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for negative stock' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product_variant][:stock_quantity] = -10
        
        post "/api/v1/products/#{product.id}/product_variants", 
             params: invalid_params, 
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for invalid price' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product_variant][:price] = -10
        
        post "/api/v1/products/#{product.id}/product_variants", 
             params: invalid_params, 
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for duplicate SKU' do
        create(:product_variant, product: product, sku: 'SKU-001')
        
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'unauthorized access' do
      it 'returns unauthorized for non-supplier' do
        customer = create(:user, role: 'customer')
        customer_headers = { 'Authorization' => "Bearer #{jwt_encode({ user_id: customer.id })}" }
        
        post "/api/v1/products/#{product.id}/product_variants", 
             params: valid_params, 
             headers: customer_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'returns not found for other supplier product' do
        other_supplier = create(:user, :supplier)
        other_profile = create(:supplier_profile, user: other_supplier)
        other_product = create(:product, supplier_profile: other_profile)
        other_headers = { 'Authorization' => "Bearer #{jwt_encode({ user_id: other_supplier.id })}" }
        
        post "/api/v1/products/#{other_product.id}/product_variants", 
             params: valid_params, 
             headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'PUT /api/v1/products/:product_id/product_variants/:id' do
    let(:variant) { create(:product_variant, product: product, sku: 'SKU-001', stock_quantity: 50) }
    
    context 'with valid parameters' do
      it 'updates variant successfully' do
        put "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
            params: { product_variant: { price: 150.0, stock_quantity: 100 } },
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        variant.reload
        expect(variant.price).to eq(150.0)
        expect(variant.stock_quantity).to eq(100)
      end
      
      it 'updates discounted price' do
        put "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
            params: { product_variant: { discounted_price: 80.0 } },
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        variant.reload
        expect(variant.discounted_price).to eq(80.0)
      end
      
      it 'updates stock quantity and recalculates available' do
        put "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
            params: { product_variant: { stock_quantity: 75 } },
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        variant.reload
        expect(variant.available_quantity).to eq(75)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors' do
        put "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
            params: { product_variant: { stock_quantity: -10 } },
            headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'unauthorized access' do
      it 'returns not found for non-existent variant' do
        put "/api/v1/products/#{product.id}/product_variants/99999", 
            params: { product_variant: { price: 150.0 } },
            headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'DELETE /api/v1/products/:product_id/product_variants/:id' do
    let!(:variant) { create(:product_variant, product: product) }
    
    context 'as supplier' do
      it 'deletes variant successfully' do
        expect {
          delete "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
                 headers: auth_headers
        }.to change(ProductVariant, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
      
      it 'deletes associated variant attributes' do
        attribute_value = create(:attribute_value)
        create(:product_variant_attribute, product_variant: variant, attribute_value: attribute_value)
        
        expect {
          delete "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
                 headers: auth_headers
        }.to change(ProductVariantAttribute, :count).by(-1)
      end
    end
    
    context 'unauthorized access' do
      it 'returns not found for non-existent variant' do
        delete "/api/v1/products/#{product.id}/product_variants/99999", 
               headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'variant availability' do
    it 'marks variant as out of stock when quantity is 0' do
      variant = create(:product_variant, product: product, stock_quantity: 0)
      
      put "/api/v1/products/#{product.id}/product_variants/#{variant.id}", 
          params: { product_variant: { stock_quantity: 0 } },
          headers: auth_headers
      
      variant.reload
      expect(variant.out_of_stock?).to be true
      expect(variant.available?).to be false
    end
    
    it 'marks variant as low stock when below threshold' do
      variant = create(:product_variant, product: product, stock_quantity: 5, low_stock_threshold: 10)
      
      variant.reload
      expect(variant.is_low_stock).to be true
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





