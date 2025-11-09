require 'rails_helper'

RSpec.describe 'API V1 Supplier & Admin Features Comprehensive', type: :request do
  let(:supplier_user) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, user: supplier_user) }
  let(:supplier_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: supplier_user.id })}" } }
  let(:admin_user) { create(:admin) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: admin_user.id })}" } }
  
  describe 'Supplier Features' do
    describe 'GET /api/v1/supplier/orders' do
      let(:customer) { create(:user) }
      let(:order) { create(:order, user: customer) }
      let(:order_item) { create(:order_item, order: order, supplier_profile: supplier_profile) }
      
      it 'returns supplier orders' do
        order_item
        
        get '/api/v1/supplier/orders', headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(1)
      end
    end
    
    describe 'POST /api/v1/supplier/orders/:item_id/confirm' do
      let(:order_item) { create(:order_item, supplier_profile: supplier_profile, fulfillment_status: 'pending') }
      
      it 'confirms order item' do
        post "/api/v1/supplier/orders/#{order_item.id}/confirm", headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        order_item.reload
        expect(order_item.fulfillment_status).to eq('confirmed')
      end
    end
    
    describe 'PUT /api/v1/supplier/orders/:item_id/ship' do
      let(:order_item) { create(:order_item, supplier_profile: supplier_profile, fulfillment_status: 'confirmed') }
      
      it 'ships order item' do
        put "/api/v1/supplier/orders/#{order_item.id}/ship", 
            params: { tracking_number: 'TRACK123', shipping_provider: 'FedEx' },
            headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        order_item.reload
        expect(order_item.fulfillment_status).to eq('shipped')
        expect(order_item.tracking_number).to eq('TRACK123')
      end
    end
    
    describe 'GET /api/v1/supplier/analytics' do
      it 'returns supplier analytics' do
        get '/api/v1/supplier/analytics', headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to have_key('sales')
        expect(json_response['data']).to have_key('revenue')
      end
    end
    
    describe 'GET /api/v1/supplier/payments' do
      it 'returns supplier payments' do
        create(:supplier_payment, supplier_profile: supplier_profile)
        
        get '/api/v1/supplier/payments', headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(1)
      end
    end
    
    describe 'GET /api/v1/supplier_profile' do
      it 'returns supplier profile' do
        get '/api/v1/supplier_profile', headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(supplier_profile.id)
      end
    end
    
    describe 'PATCH /api/v1/supplier_profile' do
      it 'updates supplier profile' do
        patch '/api/v1/supplier_profile', 
              params: { supplier_profile: { company_name: 'Updated Company' } },
              headers: supplier_headers
        
        expect(response).to have_http_status(:ok)
        supplier_profile.reload
        expect(supplier_profile.company_name).to eq('Updated Company')
      end
    end
  end
  
  describe 'Admin Features' do
    describe 'POST /api/v1/admin/login' do
      it 'authenticates admin' do
        post '/api/v1/admin/login', 
             params: { email: admin_user.email, password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to have_key('token')
      end
    end
    
    describe 'GET /api/v1/admin/users' do
      it 'returns all users' do
        create_list(:user, 3)
        
        get '/api/v1/admin/users', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end
    end
    
    describe 'PATCH /api/v1/admin/users/:id/activate' do
      let(:user) { create(:user, is_active: false) }
      
      it 'activates user' do
        patch "/api/v1/admin/users/#{user.id}/activate", headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.is_active).to be true
      end
    end
    
    describe 'GET /api/v1/admin/products' do
      it 'returns all products' do
        create_list(:product, 3)
        
        get '/api/v1/admin/products', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end
    end
    
    describe 'PATCH /api/v1/admin/products/:id/approve' do
      let(:product) { create(:product, status: 'pending') }
      
      it 'approves product' do
        patch "/api/v1/admin/products/#{product.id}/approve", headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        product.reload
        expect(product.status).to eq('active')
      end
    end
    
    describe 'GET /api/v1/admin/orders' do
      it 'returns all orders' do
        create_list(:order, 3)
        
        get '/api/v1/admin/orders', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end
    end
    
    describe 'GET /api/v1/admin/reports/sales' do
      it 'returns sales report' do
        get '/api/v1/admin/reports/sales', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
      end
    end
    
    describe 'GET /api/v1/admin/reports/revenue' do
      it 'returns revenue report' do
        get '/api/v1/admin/reports/revenue', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
      end
    end
    
    describe 'RBAC' do
      describe 'GET /api/v1/admin/rbac/roles' do
        it 'returns all roles' do
          get '/api/v1/admin/rbac/roles', headers: admin_headers
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['data']).to be_present
        end
      end
      
      describe 'POST /api/v1/admin/rbac/admins/:id/assign_role' do
        it 'assigns role to admin' do
          role = create(:rbac_role, slug: 'order_manager')
          
          post "/api/v1/admin/rbac/admins/#{admin_user.id}/assign_role", 
               params: { role_slug: 'order_manager' },
               headers: admin_headers
          
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
  
  # Helper method for JWT encoding
  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

