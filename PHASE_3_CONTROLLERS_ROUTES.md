# Phase 3: Controllers & Routes Implementation Plan

## 🎯 Backend Controllers Needed

### Payment Controllers
1. **PaymentsController** (`app/controllers/api/v1/payments_controller.rb`)
   - `POST /api/v1/payments` - Create payment
   - `GET /api/v1/payments/:id` - Get payment details
   - `GET /api/v1/orders/:order_id/payments` - Get payments for order
   - `POST /api/v1/payments/:id/refund` - Process refund

2. **PaymentRefundsController** (`app/controllers/api/v1/payment_refunds_controller.rb`)
   - `GET /api/v1/payment_refunds` - List refunds
   - `GET /api/v1/payment_refunds/:id` - Get refund details
   - `POST /api/v1/payment_refunds` - Create refund

3. **SupplierPaymentsController** (`app/controllers/api/v1/supplier_payments_controller.rb`)
   - `GET /api/v1/supplier/payments` - List supplier payments (supplier)
   - `GET /api/v1/supplier/payments/:id` - Get payment details (supplier)
   - `GET /api/v1/admin/supplier_payments` - List all supplier payments (admin)
   - `POST /api/v1/admin/supplier_payments` - Process supplier payment (admin)

### Shipping Controllers
4. **ShippingMethodsController** (`app/controllers/api/v1/shipping_methods_controller.rb`)
   - `GET /api/v1/shipping_methods` - List available shipping methods (public)
   - `GET /api/v1/admin/shipping_methods` - List all shipping methods (admin)
   - `POST /api/v1/admin/shipping_methods` - Create shipping method (admin)
   - `PATCH /api/v1/admin/shipping_methods/:id` - Update shipping method (admin)

5. **ShipmentsController** (`app/controllers/api/v1/shipments_controller.rb`)
   - `GET /api/v1/orders/:order_id/shipments` - Get shipments for order (customer)
   - `GET /api/v1/shipments/:id` - Get shipment details (customer)
   - `GET /api/v1/supplier/shipments` - List supplier shipments (supplier)
   - `POST /api/v1/supplier/shipments` - Create shipment (supplier)
   - `GET /api/v1/shipments/:id/tracking` - Get tracking events

6. **ShipmentTrackingController** (`app/controllers/api/v1/shipment_tracking_controller.rb`)
   - `GET /api/v1/shipments/:shipment_id/tracking_events` - Get tracking events
   - `POST /api/v1/supplier/shipments/:shipment_id/tracking_events` - Add tracking event (supplier)

### Coupon Controllers
7. **CouponsController** (`app/controllers/api/v1/coupons_controller.rb`)
   - `GET /api/v1/coupons/validate` - Validate coupon code (public)
   - `POST /api/v1/coupons/apply` - Apply coupon to order (customer)
   - `GET /api/v1/admin/coupons` - List all coupons (admin)
   - `POST /api/v1/admin/coupons` - Create coupon (admin)
   - `PATCH /api/v1/admin/coupons/:id` - Update coupon (admin)
   - `DELETE /api/v1/admin/coupons/:id` - Delete coupon (admin)

8. **PromotionsController** (`app/controllers/api/v1/promotions_controller.rb`)
   - `GET /api/v1/promotions` - List active promotions (public)
   - `GET /api/v1/promotions/:id` - Get promotion details (public)
   - `GET /api/v1/admin/promotions` - List all promotions (admin)
   - `POST /api/v1/admin/promotions` - Create promotion (admin)
   - `PATCH /api/v1/admin/promotions/:id` - Update promotion (admin)

### Review Controllers (Enhanced)
9. **ReviewsController** (Update existing: `app/controllers/api/v1/reviews_controller.rb`)
   - Add: `POST /api/v1/products/:product_id/reviews/:id/vote` - Vote helpful/not helpful
   - Add: `GET /api/v1/products/:product_id/reviews` - Filter by moderation_status, is_featured
   - Add: `PATCH /api/v1/admin/reviews/:id/moderate` - Moderate review (admin)
   - Add: `PATCH /api/v1/supplier/reviews/:id/respond` - Supplier response

### Return Controllers (Enhanced)
10. **ReturnRequestsController** (Update existing: `app/controllers/api/v1/return_requests_controller.rb`)
    - Add: `GET /api/v1/return_requests/:id/tracking` - Get return tracking
    - Add: `PATCH /api/v1/admin/return_requests/:id/approve` - Approve return (admin)
    - Add: `PATCH /api/v1/admin/return_requests/:id/reject` - Reject return (admin)
    - Add: `PATCH /api/v1/admin/return_requests/:id/process_refund` - Process refund (admin)
    - Add: `POST /api/v1/return_requests/:id/pickup_schedule` - Schedule pickup

---

## 📋 Routes to Add

```ruby
# config/routes.rb

namespace :api do
  namespace :v1 do
    # Payments
    resources :payments, only: [:create, :show] do
      member do
        post :refund
      end
    end
    resources :payment_refunds, only: [:index, :show, :create]
    
    # Supplier Payments
    namespace :supplier do
      resources :payments, only: [:index, :show], controller: 'supplier_payments'
    end
    
    # Shipping
    resources :shipping_methods, only: [:index]
    resources :shipments, only: [:index, :show] do
      member do
        get :tracking
      end
    end
    
    # Supplier Shipping
    namespace :supplier do
      resources :shipments, only: [:index, :create, :show] do
        member do
          post :tracking_events
        end
      end
    end
    
    # Coupons
    get 'coupons/validate', to: 'coupons#validate'
    post 'coupons/apply', to: 'coupons#apply'
    
    # Promotions
    resources :promotions, only: [:index, :show]
    
    # Reviews (enhanced)
    resources :products, only: [] do
      resources :reviews, only: [:index, :create] do
        member do
          post :vote
        end
      end
    end
    
    # Supplier Reviews
    namespace :supplier do
      resources :reviews, only: [] do
        member do
          patch :respond
        end
      end
    end
    
    # Returns (enhanced)
    resources :return_requests, only: [:create, :index, :show] do
      member do
        get :tracking
        post :pickup_schedule
      end
    end
    
    # Admin routes
    namespace :admin do
      resources :supplier_payments, only: [:index, :create, :show]
      resources :shipping_methods, only: [:index, :create, :update, :destroy]
      resources :coupons, only: [:index, :create, :update, :destroy]
      resources :promotions, only: [:index, :create, :update, :destroy]
      resources :reviews, only: [] do
        member do
          patch :moderate
        end
      end
      resources :return_requests, only: [] do
        member do
          patch :approve
          patch :reject
          patch :process_refund
        end
      end
    end
  end
end
```

---

## 📝 Implementation Priority

### Phase 3A: Core Payment & Shipping (Week 1)
1. PaymentsController
2. ShipmentsController
3. ShippingMethodsController
4. Update OrdersController to integrate payments

### Phase 3B: Coupons & Promotions (Week 2)
5. CouponsController
6. PromotionsController
7. Update OrdersController to handle coupons

### Phase 3C: Enhanced Reviews & Returns (Week 3)
8. Enhance ReviewsController
9. Enhance ReturnRequestsController

---

## 🚀 Next Steps

1. Create controller files
2. Add routes
3. Update existing controllers (OrdersController, ReviewsController, ReturnRequestsController)
4. Test all endpoints
5. Frontend integration


