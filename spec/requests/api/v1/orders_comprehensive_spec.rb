require 'rails_helper'

RSpec.describe 'API V1 Orders Comprehensive', type: :request do
  let(:customer) { create(:user, role: 'customer') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: customer.id })}" } }
  let(:supplier_profile) { create(:supplier_profile) }
  let(:product) { create(:product, supplier_profile: supplier_profile, status: 'active') }
  let(:variant) { create(:product_variant, product: product, stock_quantity: 100, price: 100.0) }
  let(:address) { create(:address, user: customer) }
  let(:cart) { create(:cart, user: customer) }
  
  before do
    create(:cart_item, cart: cart, product_variant: variant, quantity: 2)
  end
  
  describe 'POST /api/v1/orders' do
    context 'with valid parameters' do
      it 'creates order from cart' do
        expect {
          post '/api/v1/orders', 
               params: { 
                 order: {
                   shipping_address_id: address.id,
                   payment_method: 'card'
                 }
               },
               headers: auth_headers
        }.to change(Order, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['status']).to eq('pending')
      end
      
      it 'creates order items from cart items' do
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        order = Order.last
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.quantity).to eq(2)
      end
      
      it 'calculates order totals correctly' do
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        order = Order.last
        expect(order.subtotal).to eq(200.0) # 2 * 100
      end
      
      it 'clears cart after order creation' do
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        cart.reload
        expect(cart.cart_items.count).to eq(0)
      end
      
      it 'reduces variant stock quantity' do
        initial_stock = variant.stock_quantity
        
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        variant.reload
        expect(variant.stock_quantity).to eq(initial_stock - 2)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns error for empty cart' do
        empty_cart = create(:cart, user: customer)
        
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for missing address' do
        post '/api/v1/orders', 
             params: { 
               order: {
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for insufficient stock' do
        low_stock_variant = create(:product_variant, product: product, stock_quantity: 1)
        cart_item = create(:cart_item, cart: cart, product_variant: low_stock_variant, quantity: 5)
        
        post '/api/v1/orders', 
             params: { 
               order: {
                 shipping_address_id: address.id,
                 payment_method: 'card'
               }
             },
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  describe 'GET /api/v1/my-orders' do
    it 'returns user orders' do
      order1 = create(:order, user: customer, status: 'pending')
      order2 = create(:order, user: customer, status: 'confirmed')
      other_user = create(:user)
      create(:order, user: other_user)
      
      get '/api/v1/my-orders', headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(2)
    end
    
    it 'orders by created_at desc' do
      order1 = create(:order, user: customer, created_at: 2.days.ago)
      order2 = create(:order, user: customer, created_at: 1.day.ago)
      
      get '/api/v1/my-orders', headers: auth_headers
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].first['id']).to eq(order2.id)
    end
  end
  
  describe 'GET /api/v1/my-orders/:id' do
    let(:order) { create(:order, user: customer) }
    
    it 'returns order details' do
      get "/api/v1/my-orders/#{order.id}", headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(order.id)
    end
    
    it 'includes order items' do
      order_item = create(:order_item, order: order)
      
      get "/api/v1/my-orders/#{order.id}", headers: auth_headers
      
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to have_key('order_items')
    end
    
    it 'returns not found for other user order' do
      other_user = create(:user)
      other_order = create(:order, user: other_user)
      
      get "/api/v1/my-orders/#{other_order.id}", headers: auth_headers
      
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe 'PATCH /api/v1/my-orders/:id/cancel' do
    let(:order) { create(:order, user: customer, status: 'pending') }
    
    context 'with valid cancellation' do
      it 'cancels order successfully' do
        patch "/api/v1/my-orders/#{order.id}/cancel", 
              params: { cancellation_reason: 'Changed my mind about this order' },
              headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        order.reload
        expect(order.status).to eq('cancelled')
      end
      
      it 'restores variant stock' do
        order_item = create(:order_item, order: order, product_variant: variant, quantity: 2)
        initial_stock = variant.stock_quantity
        
        patch "/api/v1/my-orders/#{order.id}/cancel", 
              params: { cancellation_reason: 'Changed my mind' },
              headers: auth_headers
        
        variant.reload
        expect(variant.stock_quantity).to eq(initial_stock + 2)
      end
    end
    
    context 'with invalid cancellation' do
      it 'returns error for shipped order' do
        shipped_order = create(:order, user: customer, status: 'shipped')
        
        patch "/api/v1/my-orders/#{shipped_order.id}/cancel", 
              params: { cancellation_reason: 'Changed my mind' },
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for missing reason' do
        patch "/api/v1/my-orders/#{order.id}/cancel", 
              params: {},
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns error for short reason' do
        patch "/api/v1/my-orders/#{order.id}/cancel", 
              params: { cancellation_reason: 'Short' },
              headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  describe 'GET /api/v1/my-orders/:id/invoice' do
    let(:order) { create(:order, user: customer) }
    
    it 'generates invoice PDF' do
      get "/api/v1/my-orders/#{order.id}/invoice", headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/pdf')
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

