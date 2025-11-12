require 'rails_helper'

RSpec.describe 'API V1 Cart & Wishlist Comprehensive', type: :request do
  let(:customer) { create(:user, role: 'customer') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: customer.id })}" } }
  let(:supplier_profile) { create(:supplier_profile) }
  let(:product) { create(:product, supplier_profile: supplier_profile, status: 'active') }
  let(:variant) { create(:product_variant, product: product, stock_quantity: 100, price: 100.0) }
  
  describe 'Cart' do
    describe 'GET /api/v1/cart' do
      context 'with existing cart' do
        it 'returns cart with items' do
          cart = create(:cart, user: customer)
          cart_item = create(:cart_item, cart: cart, product_variant: variant, quantity: 2)
          
          get '/api/v1/cart', headers: auth_headers
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['data']['cart_items'].length).to eq(1)
          expect(json_response['data']['total_price']).to eq(200.0)
        end
        
        it 'calculates total price correctly' do
          cart = create(:cart, user: customer)
          variant1 = create(:product_variant, product: product, price: 100.0, discounted_price: 90.0)
          variant2 = create(:product_variant, product: product, price: 50.0)
          create(:cart_item, cart: cart, product_variant: variant1, quantity: 2)
          create(:cart_item, cart: cart, product_variant: variant2, quantity: 3)
          
          get '/api/v1/cart', headers: auth_headers
          
          json_response = JSON.parse(response.body)
          # 2 * 90 + 3 * 50 = 180 + 150 = 330
          expect(json_response['data']['total_price']).to eq(330.0)
        end
        
        it 'includes product details in cart items' do
          cart = create(:cart, user: customer)
          cart_item = create(:cart_item, cart: cart, product_variant: variant)
          
          get '/api/v1/cart', headers: auth_headers
          
          json_response = JSON.parse(response.body)
          item_data = json_response['data']['cart_items'].first
          expect(item_data).to have_key('product')
          expect(item_data).to have_key('product_variant')
        end
      end
      
      context 'without cart' do
        it 'creates cart automatically' do
          get '/api/v1/cart', headers: auth_headers
          
          expect(response).to have_http_status(:ok)
          customer.reload
          expect(customer.cart).to be_present
        end
      end
      
      context 'without authentication' do
        it 'returns unauthorized' do
          get '/api/v1/cart'
          
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
    
    describe 'POST /api/v1/cart_items' do
      it 'adds item to cart' do
        create(:cart, user: customer)
        
        expect {
          post '/api/v1/cart_items', 
               params: { product_variant_id: variant.id, quantity: 2 },
               headers: auth_headers
        }.to change(CartItem, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
      
      it 'updates quantity if item already exists' do
        cart = create(:cart, user: customer)
        cart_item = create(:cart_item, cart: cart, product_variant: variant, quantity: 2)
        
        post '/api/v1/cart_items', 
             params: { product_variant_id: variant.id, quantity: 3 },
             headers: auth_headers
        
        expect(response).to have_http_status(:created)
        cart_item.reload
        expect(cart_item.quantity).to eq(5) # 2 + 3
      end
      
      it 'creates cart if it does not exist' do
        post '/api/v1/cart_items', 
             params: { product_variant_id: variant.id, quantity: 1 },
             headers: auth_headers
        
        customer.reload
        expect(customer.cart).to be_present
      end
      
      it 'returns error for invalid variant' do
        post '/api/v1/cart_items', 
             params: { product_variant_id: 99999, quantity: 1 },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for out of stock variant' do
        out_of_stock_variant = create(:product_variant, product: product, stock_quantity: 0)
        
        post '/api/v1/cart_items', 
             params: { product_variant_id: out_of_stock_variant.id, quantity: 1 },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    describe 'PUT /api/v1/cart_items/:id' do
      let(:cart) { create(:cart, user: customer) }
      let(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
      
      it 'updates cart item quantity' do
        put "/api/v1/cart_items/#{cart_item.id}", 
            params: { quantity: 5 },
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        cart_item.reload
        expect(cart_item.quantity).to eq(5)
      end
      
      it 'recalculates total price after update' do
        put "/api/v1/cart_items/#{cart_item.id}", 
            params: { quantity: 5 },
            headers: auth_headers
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['total_price']).to eq(500.0) # 5 * 100
      end
      
      it 'returns error for invalid quantity' do
        put "/api/v1/cart_items/#{cart_item.id}", 
            params: { quantity: -1 },
            headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns not found for non-existent item' do
        put '/api/v1/cart_items/99999', 
            params: { quantity: 5 },
            headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
    
    describe 'DELETE /api/v1/cart_items/:id' do
      let(:cart) { create(:cart, user: customer) }
      let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
      
      it 'removes item from cart' do
        expect {
          delete "/api/v1/cart_items/#{cart_item.id}", headers: auth_headers
        }.to change(CartItem, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
      end
      
      it 'recalculates total price after removal' do
        variant2 = create(:product_variant, product: product, price: 50.0)
        cart_item2 = create(:cart_item, cart: cart, product_variant: variant2, quantity: 1)
        
        delete "/api/v1/cart_items/#{cart_item.id}", headers: auth_headers
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['total_price']).to eq(50.0)
      end
    end
  end
  
  describe 'Wishlist' do
    describe 'GET /api/v1/wishlist/items' do
      context 'with existing wishlist' do
        it 'returns wishlist items' do
          wishlist = create(:wishlist, user: customer)
          wishlist_item = create(:wishlist_item, wishlist: wishlist, product_variant: variant)
          
          get '/api/v1/wishlist/items', headers: auth_headers
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['data'].length).to eq(1)
        end
        
        it 'includes product details' do
          wishlist = create(:wishlist, user: customer)
          wishlist_item = create(:wishlist_item, wishlist: wishlist, product_variant: variant)
          
          get '/api/v1/wishlist/items', headers: auth_headers
          
          json_response = JSON.parse(response.body)
          item_data = json_response['data'].first
          expect(item_data).to have_key('product')
          expect(item_data).to have_key('product_variant')
        end
      end
      
      context 'without wishlist' do
        it 'creates wishlist automatically' do
          get '/api/v1/wishlist/items', headers: auth_headers
          
          expect(response).to have_http_status(:ok)
          customer.reload
          expect(customer.wishlist).to be_present
        end
      end
    end
    
    describe 'POST /api/v1/wishlist/items' do
      it 'adds item to wishlist' do
        create(:wishlist, user: customer)
        
        expect {
          post '/api/v1/wishlist/items', 
               params: { product_variant_id: variant.id },
               headers: auth_headers
        }.to change(WishlistItem, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
      
      it 'does not add duplicate items' do
        wishlist = create(:wishlist, user: customer)
        create(:wishlist_item, wishlist: wishlist, product_variant: variant)
        
        expect {
          post '/api/v1/wishlist/items', 
               params: { product_variant_id: variant.id },
               headers: auth_headers
        }.not_to change(WishlistItem, :count)
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to include('already in wishlist')
      end
      
      it 'creates wishlist if it does not exist' do
        post '/api/v1/wishlist/items', 
             params: { product_variant_id: variant.id },
             headers: auth_headers
        
        customer.reload
        expect(customer.wishlist).to be_present
      end
    end
    
    describe 'DELETE /api/v1/wishlist/items/:id' do
      let(:wishlist) { create(:wishlist, user: customer) }
      let!(:wishlist_item) { create(:wishlist_item, wishlist: wishlist, product_variant: variant) }
      
      it 'removes item from wishlist' do
        expect {
          delete "/api/v1/wishlist/items/#{wishlist_item.id}", headers: auth_headers
        }.to change(WishlistItem, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns not found for non-existent item' do
        delete '/api/v1/wishlist/items/99999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





