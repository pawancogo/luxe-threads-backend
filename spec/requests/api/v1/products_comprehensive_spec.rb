require 'rails_helper'

RSpec.describe 'API V1 Products Comprehensive', type: :request do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:category) { create(:category) }
  let(:brand) { create(:brand) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
  
  before do
    supplier_profile # Ensure supplier profile exists
  end
  
  describe 'GET /api/v1/products' do
    context 'as supplier' do
      it 'returns supplier products' do
        products = create_list(:product, 3, supplier_profile: supplier_profile)
        
        get '/api/v1/products', headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data'].length).to eq(3)
      end
      
      it 'only returns products for current supplier' do
        other_supplier = create(:user, :supplier)
        other_profile = create(:supplier_profile, user: other_supplier)
        
        create(:product, supplier_profile: supplier_profile)
        create(:product, supplier_profile: other_profile)
        
        get '/api/v1/products', headers: auth_headers
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['supplier_profile_id']).to eq(supplier_profile.id)
      end
      
      it 'includes product associations' do
        product = create(:product, supplier_profile: supplier_profile, category: category, brand: brand)
        
        get '/api/v1/products', headers: auth_headers
        
        json_response = JSON.parse(response.body)
        product_data = json_response['data'].first
        expect(product_data).to have_key('category')
        expect(product_data).to have_key('brand')
      end
      
      it 'filters by status' do
        create(:product, supplier_profile: supplier_profile, status: 'active')
        create(:product, supplier_profile: supplier_profile, status: 'pending')
        
        get '/api/v1/products', params: { status: 'active' }, headers: auth_headers
        
        json_response = JSON.parse(response.body)
        expect(json_response['data'].all? { |p| p['status'] == 'active' }).to be true
      end
    end
    
    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/products'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET /api/v1/products/:id' do
    let(:product) { create(:product, supplier_profile: supplier_profile) }
    
    context 'as supplier' do
      it 'returns product details' do
        get "/api/v1/products/#{product.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['id']).to eq(product.id)
        expect(json_response['data']['name']).to eq(product.name)
      end
      
      it 'includes all product fields' do
        get "/api/v1/products/#{product.id}", headers: auth_headers
        
        json_response = JSON.parse(response.body)
        data = json_response['data']
        expect(data).to have_key('name')
        expect(data).to have_key('description')
        expect(data).to have_key('status')
        expect(data).to have_key('category')
        expect(data).to have_key('brand')
        expect(data).to have_key('product_variants')
      end
      
      it 'returns not found for non-existent product' do
        get '/api/v1/products/99999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
      
      it 'returns unauthorized for other supplier product' do
        other_supplier = create(:user, :supplier)
        other_profile = create(:supplier_profile, user: other_supplier)
        other_product = create(:product, supplier_profile: other_profile)
        
        get "/api/v1/products/#{other_product.id}", headers: auth_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'POST /api/v1/products' do
    let(:valid_params) do
      {
        product: {
          name: 'Test Product',
          description: 'Test Description',
          short_description: 'Short desc',
          category_id: category.id,
          brand_id: brand.id,
          product_type: 'physical',
          base_price: 100.0,
          base_discounted_price: 90.0,
          base_mrp: 120.0,
          highlights: ['Feature 1', 'Feature 2'],
          tags: ['tag1', 'tag2']
        }
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new product' do
        expect {
          post '/api/v1/products', params: valid_params, headers: auth_headers
        }.to change(Product, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['name']).to eq('Test Product')
      end
      
      it 'assigns product to supplier profile' do
        post '/api/v1/products', params: valid_params, headers: auth_headers
        
        json_response = JSON.parse(response.body)
        product_id = json_response['data']['id']
        product = Product.find(product_id)
        expect(product.supplier_profile).to eq(supplier_profile)
      end
      
      it 'sets default status to pending' do
        post '/api/v1/products', params: valid_params, headers: auth_headers
        
        json_response = JSON.parse(response.body)
        product_id = json_response['data']['id']
        product = Product.find(product_id)
        expect(product.status).to eq('pending')
      end
      
      it 'saves highlights and tags' do
        post '/api/v1/products', params: valid_params, headers: auth_headers
        
        json_response = JSON.parse(response.body)
        product_id = json_response['data']['id']
        product = Product.find(product_id)
        expect(product.highlights).to include('Feature 1')
        expect(product.tags).to include('tag1')
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors for missing name' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product][:name] = nil
        
        post '/api/v1/products', params: invalid_params, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end
      
      it 'returns validation errors for missing category' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product][:category_id] = nil
        
        post '/api/v1/products', params: invalid_params, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns validation errors for invalid price' do
        invalid_params = valid_params.deep_dup
        invalid_params[:product][:base_price] = -10
        
        post '/api/v1/products', params: invalid_params, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'without supplier profile' do
      let(:user_without_profile) { create(:user, :supplier) }
      let(:auth_headers_no_profile) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user_without_profile.id })}" } }
      
      it 'returns error' do
        post '/api/v1/products', params: valid_params, headers: auth_headers_no_profile
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  describe 'PATCH /api/v1/products/:id' do
    let(:product) { create(:product, supplier_profile: supplier_profile) }
    
    context 'with valid parameters' do
      it 'updates product successfully' do
        patch "/api/v1/products/#{product.id}", 
              params: { product: { name: 'Updated Name', description: 'Updated Description' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        product.reload
        expect(product.name).to eq('Updated Name')
        expect(product.description).to eq('Updated Description')
      end
      
      it 'updates pricing fields' do
        patch "/api/v1/products/#{product.id}", 
              params: { product: { base_price: 150.0, base_discounted_price: 130.0 } },
              headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        product.reload
        expect(product.base_price).to eq(150.0)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns validation errors' do
        patch "/api/v1/products/#{product.id}", 
              params: { product: { name: '' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'unauthorized access' do
      it 'returns unauthorized for other supplier product' do
        other_supplier = create(:user, :supplier)
        other_profile = create(:supplier_profile, user: other_supplier)
        other_product = create(:product, supplier_profile: other_profile)
        
        patch "/api/v1/products/#{other_product.id}", 
              params: { product: { name: 'Updated' } },
              headers: auth_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'DELETE /api/v1/products/:id' do
    let!(:product) { create(:product, supplier_profile: supplier_profile) }
    
    context 'as supplier' do
      it 'deletes product successfully' do
        expect {
          delete "/api/v1/products/#{product.id}", headers: auth_headers
        }.to change(Product, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
      
      it 'deletes associated variants' do
        variant = create(:product_variant, product: product)
        
        expect {
          delete "/api/v1/products/#{product.id}", headers: auth_headers
        }.to change(ProductVariant, :count).by(-1)
      end
    end
    
    context 'unauthorized access' do
      it 'returns unauthorized for other supplier product' do
        other_supplier = create(:user, :supplier)
        other_profile = create(:supplier_profile, user: other_supplier)
        other_product = create(:product, supplier_profile: other_profile)
        
        delete "/api/v1/products/#{other_product.id}", headers: auth_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





