require 'rails_helper'

RSpec.describe 'API V1 Payments, Shipping, Returns & Reviews', type: :request do
  let(:customer) { create(:user, role: 'customer') }
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:customer_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: customer.id })}" } }
  let(:supplier_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
  let(:order) { create(:order, user: customer, status: 'pending') }
  let(:order_item) { create(:order_item, order: order, supplier_profile: supplier_profile) }
  
  describe 'Payments' do
    describe 'POST /api/v1/orders/:order_id/payments' do
      it 'creates payment for order' do
        expect {
          post "/api/v1/orders/#{order.id}/payments", 
               params: {
                 payment: {
                   amount: order.total_amount,
                   payment_method: 'card',
                   payment_gateway: 'stripe',
                   transaction_id: 'txn_123'
                 }
               },
               headers: customer_headers
        }.to change(Payment, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
      
      it 'updates order status to confirmed' do
        post "/api/v1/orders/#{order.id}/payments", 
             params: {
               payment: {
                 amount: order.total_amount,
                 payment_method: 'card',
                 payment_gateway: 'stripe',
                 transaction_id: 'txn_123'
               }
             },
             headers: customer_headers
        
        order.reload
        expect(order.status).to eq('confirmed')
      end
    end
    
    describe 'GET /api/v1/payments/:id' do
      let(:payment) { create(:payment, order: order) }
      
      it 'returns payment details' do
        get "/api/v1/payments/#{payment.id}", headers: customer_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(payment.id)
      end
    end
    
    describe 'POST /api/v1/payments/:id/refund' do
      let(:payment) { create(:payment, order: order, status: 'completed') }
      
      it 'creates refund request' do
        expect {
          post "/api/v1/payments/#{payment.id}/refund", 
               params: { refund_amount: 100.0, reason: 'Customer request' },
               headers: customer_headers
        }.to change(PaymentRefund, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
    end
  end
  
  describe 'Shipping' do
    describe 'GET /api/v1/shipping_methods' do
      it 'returns available shipping methods' do
        create(:shipping_method, name: 'Standard', active: true)
        create(:shipping_method, name: 'Express', active: true)
        
        get '/api/v1/shipping_methods'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
      end
    end
    
    describe 'GET /api/v1/orders/:order_id/shipments' do
      let(:confirmed_order) { create(:order, user: customer, status: 'confirmed') }
      
      it 'returns order shipments' do
        shipment = create(:shipment, order: confirmed_order)
        
        get "/api/v1/orders/#{confirmed_order.id}/shipments", headers: customer_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(1)
      end
    end
    
    describe 'GET /api/v1/shipments/:id/tracking' do
      let(:shipment) { create(:shipment, order: order) }
      
      it 'returns tracking events' do
        create(:shipment_tracking_event, shipment: shipment, status: 'in_transit')
        
        get "/api/v1/shipments/#{shipment.id}/tracking", headers: customer_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
      end
    end
  end
  
  describe 'Returns' do
    let(:delivered_order) { create(:order, user: customer, status: 'delivered') }
    let(:delivered_order_item) { create(:order_item, order: delivered_order, supplier_profile: supplier_profile) }
    
    describe 'POST /api/v1/return_requests' do
      it 'creates return request' do
        expect {
          post '/api/v1/return_requests', 
               params: {
                 return_request: {
                   order_item_id: delivered_order_item.id,
                   return_reason: 'Defective product',
                   return_quantity: 1
                 }
               },
               headers: customer_headers
        }.to change(ReturnRequest, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
      
      it 'returns error for non-returnable item' do
        non_returnable_item = create(:order_item, order: delivered_order, is_returnable: false)
        
        post '/api/v1/return_requests', 
             params: {
               return_request: {
                 order_item_id: non_returnable_item.id,
                 return_reason: 'Defective',
                 return_quantity: 1
               }
             },
             headers: customer_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    describe 'GET /api/v1/my-returns' do
      it 'returns user return requests' do
        return_request = create(:return_request, order_item: delivered_order_item)
        
        get '/api/v1/my-returns', headers: customer_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(1)
      end
    end
    
    describe 'POST /api/v1/supplier/returns/:id/approve' do
      let(:return_request) { create(:return_request, order_item: delivered_order_item, status: 'pending') }
      
      it 'approves return request' do
        post "/api/v1/supplier/returns/#{return_request.id}/approve", 
             params: { notes: 'Approved for return' },
             headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        return_request.reload
        expect(return_request.status).to eq('approved')
      end
    end
    
    describe 'POST /api/v1/supplier/returns/:id/reject' do
      let(:return_request) { create(:return_request, order_item: delivered_order_item, status: 'pending') }
      
      it 'rejects return request' do
        post "/api/v1/supplier/returns/#{return_request.id}/reject", 
             params: { reason: 'Outside return window' },
             headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        return_request.reload
        expect(return_request.status).to eq('rejected')
      end
    end
  end
  
  describe 'Reviews' do
    let(:product) { create(:product, supplier_profile: supplier_profile, status: 'active') }
    let(:delivered_order_item) { create(:order_item, order: delivered_order, product: product) }
    let(:delivered_order) { create(:order, user: customer, status: 'delivered') }
    
    describe 'POST /api/v1/products/:product_id/reviews' do
      it 'creates review for product' do
        expect {
          post "/api/v1/products/#{product.id}/reviews", 
               params: {
                 review: {
                   rating: 5,
                   comment: 'Great product!',
                   order_item_id: delivered_order_item.id
                 }
               },
               headers: customer_headers
        }.to change(Review, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
      
      it 'returns error for invalid rating' do
        post "/api/v1/products/#{product.id}/reviews", 
             params: {
               review: {
                 rating: 6,
                 comment: 'Invalid rating',
                 order_item_id: delivered_order_item.id
               }
             },
             headers: customer_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    describe 'GET /api/v1/products/:product_id/reviews' do
      it 'returns product reviews' do
        create(:review, product: product, user: customer, rating: 5)
        create(:review, product: product, user: create(:user), rating: 4)
        
        get "/api/v1/products/#{product.id}/reviews"
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
      end
    end
    
    describe 'POST /api/v1/products/:product_id/reviews/:id/vote' do
      let(:review) { create(:review, product: product, user: customer) }
      
      it 'votes helpful on review' do
        post "/api/v1/products/#{product.id}/reviews/#{review.id}/vote", 
             params: { helpful: true },
             headers: customer_headers
        
        expect(response).to have_http_status(:ok)
        review.reload
        expect(review.helpful_count).to eq(1)
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

