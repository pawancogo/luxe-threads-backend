require 'rails_helper'

RSpec.describe 'API V1 Categories, Brands & Attributes', type: :request do
  describe 'Categories' do
    describe 'GET /api/v1/categories' do
      it 'returns all categories without authentication' do
        categories = create_list(:category, 3)
        
        get '/api/v1/categories'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data'].length).to eq(3)
      end
      
      it 'includes parent category information' do
        parent = create(:category, name: 'Parent')
        child = create(:category, name: 'Child', parent: parent)
        
        get '/api/v1/categories'
        
        json_response = JSON.parse(response.body)
        child_data = json_response['data'].find { |c| c['name'] == 'Child' }
        expect(child_data['parent_id']).to eq(parent.id)
        expect(child_data['parent']).to be_present
      end
      
      it 'includes subcategories' do
        parent = create(:category, name: 'Parent')
        create_list(:category, 2, parent: parent)
        
        get '/api/v1/categories'
        
        json_response = JSON.parse(response.body)
        parent_data = json_response['data'].find { |c| c['name'] == 'Parent' }
        expect(parent_data['sub_categories'].length).to eq(2)
      end
      
      it 'orders categories by sort_order and name' do
        create(:category, name: 'B Category', sort_order: 2)
        create(:category, name: 'A Category', sort_order: 1)
        
        get '/api/v1/categories'
        
        json_response = JSON.parse(response.body)
        names = json_response['data'].map { |c| c['name'] }
        expect(names).to eq(['A Category', 'B Category'])
      end
    end
    
    describe 'GET /api/v1/categories/:id' do
      it 'returns category by ID' do
        category = create(:category, name: 'Test Category')
        
        get "/api/v1/categories/#{category.id}"
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['name']).to eq('Test Category')
      end
      
      it 'returns category by slug' do
        category = create(:category, name: 'Test Category', slug: 'test-category')
        
        get '/api/v1/categories/test-category'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['slug']).to eq('test-category')
      end
      
      it 'returns not found for non-existent category' do
        get '/api/v1/categories/99999'
        
        expect(response).to have_http_status(:not_found)
      end
      
      it 'includes all category fields' do
        category = create(:category, 
                         short_description: 'Short desc',
                         image_url: 'https://example.com/image.jpg',
                         featured: true)
        
        get "/api/v1/categories/#{category.id}"
        
        json_response = JSON.parse(response.body)
        data = json_response['data']
        expect(data).to have_key('short_description')
        expect(data).to have_key('image_url')
        expect(data).to have_key('featured')
        expect(data).to have_key('products_count')
      end
    end
    
    describe 'GET /api/v1/categories/navigation' do
      it 'returns root categories for navigation' do
        root1 = create(:category, name: 'Root 1')
        root2 = create(:category, name: 'Root 2')
        create(:category, parent: root1)
        
        get '/api/v1/categories/navigation'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
        expect(json_response['data'].map { |c| c['name'] }).to include('Root 1', 'Root 2')
      end
      
      it 'includes subcategories in navigation' do
        root = create(:category, name: 'Root')
        sub1 = create(:category, name: 'Sub 1', parent: root)
        sub2 = create(:category, name: 'Sub 2', parent: root)
        
        get '/api/v1/categories/navigation'
        
        json_response = JSON.parse(response.body)
        root_data = json_response['data'].find { |c| c['name'] == 'Root' }
        expect(root_data['subcategories'].first['items']).to include('Sub 1', 'Sub 2')
      end
    end
  end
  
  describe 'Brands' do
    describe 'GET /api/v1/brands' do
      it 'returns all active brands without authentication' do
        active_brand = create(:brand, name: 'Active Brand', active: true)
        create(:brand, name: 'Inactive Brand', active: false)
        
        get '/api/v1/brands'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['name']).to eq('Active Brand')
      end
      
      it 'orders brands by name' do
        create(:brand, name: 'Z Brand', active: true)
        create(:brand, name: 'A Brand', active: true)
        
        get '/api/v1/brands'
        
        json_response = JSON.parse(response.body)
        names = json_response['data'].map { |b| b['name'] }
        expect(names).to eq(['A Brand', 'Z Brand'])
      end
      
      it 'includes brand details' do
        brand = create(:brand, 
                      name: 'Test Brand',
                      logo_url: 'https://example.com/logo.jpg',
                      country_of_origin: 'USA',
                      founded_year: 2000,
                      active: true)
        
        get '/api/v1/brands'
        
        json_response = JSON.parse(response.body)
        brand_data = json_response['data'].first
        expect(brand_data).to have_key('logo_url')
        expect(brand_data).to have_key('country_of_origin')
        expect(brand_data).to have_key('founded_year')
        expect(brand_data).to have_key('products_count')
      end
    end
    
    describe 'GET /api/v1/brands/:id' do
      it 'returns brand by ID' do
        brand = create(:brand, name: 'Test Brand', active: true)
        
        get "/api/v1/brands/#{brand.id}"
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['name']).to eq('Test Brand')
      end
      
      it 'returns brand by slug' do
        brand = create(:brand, name: 'Test Brand', slug: 'test-brand', active: true)
        
        get '/api/v1/brands/test-brand'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['slug']).to eq('test-brand')
      end
      
      it 'returns not found for non-existent brand' do
        get '/api/v1/brands/99999'
        
        expect(response).to have_http_status(:not_found)
      end
      
      it 'includes all brand fields' do
        brand = create(:brand,
                      name: 'Test Brand',
                      meta_title: 'Meta Title',
                      meta_description: 'Meta Description',
                      active: true)
        
        get "/api/v1/brands/#{brand.id}"
        
        json_response = JSON.parse(response.body)
        data = json_response['data']
        expect(data).to have_key('meta_title')
        expect(data).to have_key('meta_description')
        expect(data).to have_key('products_count')
      end
    end
  end
  
  describe 'Attribute Types' do
    let(:supplier_user) { create(:user, :supplier) }
    let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
    
    describe 'GET /api/v1/attribute_types' do
      context 'as supplier' do
        it 'returns all attribute types' do
          create(:attribute_type, name: 'Color')
          create(:attribute_type, name: 'Size')
          
          get '/api/v1/attribute_types', headers: auth_headers
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['data'].length).to eq(2)
        end
        
        it 'includes attribute values' do
          attr_type = create(:attribute_type, name: 'Color')
          value1 = create(:attribute_value, attribute_type: attr_type, value: 'Red')
          value2 = create(:attribute_value, attribute_type: attr_type, value: 'Blue')
          
          get '/api/v1/attribute_types', headers: auth_headers
          
          json_response = JSON.parse(response.body)
          color_attr = json_response['data'].find { |a| a['name'] == 'Color' }
          expect(color_attr['values'].length).to eq(2)
          expect(color_attr['values'].map { |v| v['value'] }).to include('Red', 'Blue')
        end
        
        it 'filters by level (product)' do
          create(:attribute_type, name: 'Material') # Product level
          create(:attribute_type, name: 'Color') # Variant level
          
          get '/api/v1/attribute_types', params: { level: 'product' }, headers: auth_headers
          
          json_response = JSON.parse(response.body)
          # Should only return product-level attributes
          expect(json_response['data'].any? { |a| a['name'] == 'Material' }).to be true
        end
        
        it 'filters by level (variant)' do
          create(:attribute_type, name: 'Material') # Product level
          create(:attribute_type, name: 'Color') # Variant level
          
          get '/api/v1/attribute_types', params: { level: 'variant' }, headers: auth_headers
          
          json_response = JSON.parse(response.body)
          # Should only return variant-level attributes
          expect(json_response['data'].any? { |a| a['name'] == 'Color' }).to be true
        end
        
        it 'filters size values by category' do
          category = create(:category, name: 'Clothing')
          size_attr = create(:attribute_type, name: 'Size')
          create(:attribute_value, attribute_type: size_attr, value: 'S')
          create(:attribute_value, attribute_type: size_attr, value: 'M')
          create(:attribute_value, attribute_type: size_attr, value: 'L')
          
          get '/api/v1/attribute_types', 
              params: { category_id: category.id },
              headers: auth_headers
          
          json_response = JSON.parse(response.body)
          size_attr_data = json_response['data'].find { |a| a['name'] == 'Size' }
          expect(size_attr_data).to be_present
        end
        
        it 'includes color hex codes for color attributes' do
          color_attr = create(:attribute_type, name: 'Color')
          create(:attribute_value, attribute_type: color_attr, value: 'Red')
          
          get '/api/v1/attribute_types', headers: auth_headers
          
          json_response = JSON.parse(response.body)
          color_data = json_response['data'].find { |a| a['name'] == 'Color' }
          red_value = color_data['values'].find { |v| v['value'] == 'Red' }
          expect(red_value).to have_key('hex_code')
        end
      end
      
      context 'without authentication' do
        it 'returns unauthorized' do
          get '/api/v1/attribute_types'
          
          expect(response).to have_http_status(:unauthorized)
        end
      end
      
      context 'as non-supplier' do
        it 'returns unauthorized for customer' do
          customer = create(:user, role: 'customer')
          customer_headers = { 'Authorization' => "Bearer #{jwt_encode({ user_id: customer.id })}" }
          
          get '/api/v1/attribute_types', headers: customer_headers
          
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





