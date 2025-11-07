# Production Schema Design - Chunk 2: Advanced Features
## Enterprise-Grade E-Commerce Platform (Myntra/Meesho Level)

This document covers **advanced features** that make the platform production-ready and scalable.

---

## 📋 Table of Contents

1. Payment & Financial System
2. Logistics & Shipping
3. Coupons & Promotions
4. Reviews & Ratings
5. Returns & Refunds
6. Inventory Management
7. Analytics & Tracking

---

## 1. PAYMENT & FINANCIAL SYSTEM

### 1.1 `payments` Table (Payment Transactions)

```sql
CREATE TABLE payments (
  id BIGSERIAL PRIMARY KEY,
  payment_id VARCHAR(100) NOT NULL UNIQUE, -- External payment ID
  order_id BIGINT NOT NULL REFERENCES orders(id),
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Payment Details
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  payment_method VARCHAR(50) NOT NULL,
  -- Values: cod, credit_card, debit_card, upi, wallet, netbanking, emi
  
  -- Payment Gateway
  payment_gateway VARCHAR(50), -- razorpay, stripe, payu, paytm
  gateway_transaction_id VARCHAR(255),
  gateway_payment_id VARCHAR(255),
  gateway_response JSONB, -- Full response from gateway
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, processing, completed, failed, refunded, partially_refunded
  failure_reason TEXT,
  
  -- Payment Information (for card/UPI)
  card_last4 VARCHAR(4),
  card_brand VARCHAR(50), -- visa, mastercard, amex
  upi_id VARCHAR(255),
  wallet_type VARCHAR(50), -- paytm, phonepe, amazon_pay
  
  -- Refund Information
  refund_amount DECIMAL(10, 2) DEFAULT 0,
  refund_status VARCHAR(50), -- pending, processing, completed, failed
  refund_id VARCHAR(255),
  refunded_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded')),
  CHECK (amount > 0),
  
  -- Indexes
  INDEX idx_payments_order (order_id),
  INDEX idx_payments_user (user_id),
  INDEX idx_payments_status (status),
  INDEX idx_payments_payment_id (payment_id),
  INDEX idx_payments_gateway_transaction (gateway_transaction_id),
  INDEX idx_payments_created_at (created_at)
);
```

---

### 1.2 `payment_refunds` Table (Refund Tracking)

```sql
CREATE TABLE payment_refunds (
  id BIGSERIAL PRIMARY KEY,
  refund_id VARCHAR(100) NOT NULL UNIQUE,
  payment_id BIGINT NOT NULL REFERENCES payments(id),
  order_id BIGINT NOT NULL REFERENCES orders(id),
  order_item_id BIGINT REFERENCES order_items(id), -- If partial refund
  
  -- Refund Details
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  reason VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, processing, completed, failed, cancelled
  
  -- Payment Gateway
  gateway_refund_id VARCHAR(255),
  gateway_response JSONB,
  
  -- Processing
  processed_by_id BIGINT REFERENCES users(id), -- Admin who processed
  processed_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  CHECK (amount > 0),
  
  -- Indexes
  INDEX idx_payment_refunds_payment (payment_id),
  INDEX idx_payment_refunds_order (order_id),
  INDEX idx_payment_refunds_status (status),
  INDEX idx_payment_refunds_refund_id (refund_id)
);
```

---

### 1.3 `supplier_payments` Table (Supplier Payouts)

```sql
CREATE TABLE supplier_payments (
  id BIGSERIAL PRIMARY KEY,
  payment_id VARCHAR(100) NOT NULL UNIQUE,
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id),
  
  -- Payment Details
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  commission_deducted DECIMAL(10, 2) DEFAULT 0,
  net_amount DECIMAL(10, 2) NOT NULL, -- amount - commission
  
  -- Payment Method
  payment_method VARCHAR(50) NOT NULL, -- bank_transfer, upi, neft, rtgs
  bank_account_number VARCHAR(50),
  bank_ifsc_code VARCHAR(20),
  transaction_reference VARCHAR(255),
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, processing, completed, failed, cancelled
  failure_reason TEXT,
  
  -- Period
  period_start_date DATE NOT NULL,
  period_end_date DATE NOT NULL,
  order_items_count INTEGER DEFAULT 0,
  
  -- Processing
  processed_by_id BIGINT REFERENCES admins(id),
  processed_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  CHECK (amount > 0),
  CHECK (net_amount > 0),
  
  -- Indexes
  INDEX idx_supplier_payments_supplier (supplier_profile_id),
  INDEX idx_supplier_payments_status (status),
  INDEX idx_supplier_payments_period (period_start_date, period_end_date),
  INDEX idx_supplier_payments_payment_id (payment_id)
);
```

---

### 1.4 `payment_transactions` Table (Transaction Log)

```sql
CREATE TABLE payment_transactions (
  id BIGSERIAL PRIMARY KEY,
  transaction_id VARCHAR(100) NOT NULL UNIQUE,
  payment_id BIGINT REFERENCES payments(id),
  order_id BIGINT REFERENCES orders(id),
  
  -- Transaction Details
  transaction_type VARCHAR(50) NOT NULL,
  -- Values: payment, refund, payout, adjustment
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  
  -- Status
  status VARCHAR(50) NOT NULL,
  -- Values: pending, processing, completed, failed
  
  -- Gateway Response
  gateway_response JSONB,
  failure_reason TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_payment_transactions_payment (payment_id),
  INDEX idx_payment_transactions_order (order_id),
  INDEX idx_payment_transactions_type (transaction_type),
  INDEX idx_payment_transactions_status (status),
  INDEX idx_payment_transactions_created_at (created_at)
);
```

---

## 2. LOGISTICS & SHIPPING

### 2.1 `shipping_methods` Table

```sql
CREATE TABLE shipping_methods (
  id BIGSERIAL PRIMARY KEY,
  
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  
  -- Shipping Provider
  provider VARCHAR(100), -- delhivery, fedex, bluedart, etc.
  provider_code VARCHAR(50),
  
  -- Pricing
  base_charge DECIMAL(10, 2) DEFAULT 0,
  per_kg_charge DECIMAL(10, 2) DEFAULT 0,
  free_shipping_above DECIMAL(10, 2),
  
  -- Delivery Time
  estimated_days_min INTEGER,
  estimated_days_max INTEGER,
  
  -- Coverage
  available_pincodes TEXT[], -- Array of pincodes
  excluded_pincodes TEXT[], -- Array of excluded pincodes
  available_zones JSONB DEFAULT '{}', -- Zone-based availability
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_cod_available BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_shipping_methods_code (code),
  INDEX idx_shipping_methods_active (is_active)
);
```

---

### 2.2 `shipments` Table (Shipment Tracking)

```sql
CREATE TABLE shipments (
  id BIGSERIAL PRIMARY KEY,
  shipment_id VARCHAR(100) NOT NULL UNIQUE,
  order_id BIGINT NOT NULL REFERENCES orders(id),
  order_item_id BIGINT REFERENCES order_items(id), -- For split shipments
  
  -- Shipping Details
  shipping_method_id BIGINT REFERENCES shipping_methods(id),
  shipping_provider VARCHAR(100),
  tracking_number VARCHAR(255) UNIQUE,
  tracking_url VARCHAR(500),
  
  -- Addresses
  from_address JSONB NOT NULL, -- Warehouse address
  to_address JSONB NOT NULL, -- Delivery address
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, label_created, picked_up, in_transit, 
  --         out_for_delivery, delivered, failed, returned
  status_updated_at TIMESTAMP,
  
  -- Dates
  shipped_at TIMESTAMP,
  estimated_delivery_date DATE,
  actual_delivery_date DATE,
  
  -- Delivery Details
  delivered_to VARCHAR(255), -- Person who received
  delivery_notes TEXT,
  delivery_proof_image_url VARCHAR(500),
  
  -- Weight & Dimensions
  weight_kg DECIMAL(8, 3),
  length_cm DECIMAL(8, 2),
  width_cm DECIMAL(8, 2),
  height_cm DECIMAL(8, 2),
  
  -- Charges
  shipping_charge DECIMAL(10, 2),
  cod_charge DECIMAL(10, 2),
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'label_created', 'picked_up', 'in_transit', 
                    'out_for_delivery', 'delivered', 'failed', 'returned')),
  
  -- Indexes
  INDEX idx_shipments_order (order_id),
  INDEX idx_shipments_tracking (tracking_number),
  INDEX idx_shipments_status (status),
  INDEX idx_shipments_provider (shipping_provider)
);
```

---

### 2.3 `shipment_tracking_events` Table (Detailed Tracking)

```sql
CREATE TABLE shipment_tracking_events (
  id BIGSERIAL PRIMARY KEY,
  shipment_id BIGINT NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
  
  -- Event Details
  event_type VARCHAR(50) NOT NULL,
  -- Values: label_created, picked_up, in_transit, out_for_delivery, 
  --         delivered, failed, returned
  event_description TEXT,
  location VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(20),
  
  -- Timestamps
  event_time TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Source
  source VARCHAR(50) DEFAULT 'provider', -- provider, manual, system
  
  -- Indexes
  INDEX idx_shipment_tracking_events_shipment (shipment_id),
  INDEX idx_shipment_tracking_events_time (event_time)
);
```

---

## 3. COUPONS & PROMOTIONS

### 3.1 `coupons` Table (Discount Coupons)

```sql
CREATE TABLE coupons (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  
  -- Coupon Details
  name VARCHAR(255) NOT NULL,
  description TEXT,
  coupon_type VARCHAR(50) NOT NULL,
  -- Values: percentage, fixed_amount, free_shipping, buy_one_get_one
  
  -- Discount
  discount_value DECIMAL(10, 2) NOT NULL,
  -- For percentage: 10 means 10%
  -- For fixed: 100 means ₹100
  max_discount_amount DECIMAL(10, 2), -- For percentage coupons
  min_order_amount DECIMAL(10, 2) DEFAULT 0,
  
  -- Validity
  valid_from TIMESTAMP NOT NULL,
  valid_until TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Usage Limits
  max_uses INTEGER, -- Total uses allowed
  max_uses_per_user INTEGER DEFAULT 1,
  current_uses INTEGER DEFAULT 0,
  
  -- Applicability
  applicable_categories BIGINT[], -- Category IDs
  applicable_products BIGINT[], -- Product IDs
  applicable_brands BIGINT[], -- Brand IDs
  applicable_suppliers BIGINT[], -- Supplier IDs
  exclude_categories BIGINT[],
  exclude_products BIGINT[],
  
  -- User Restrictions
  new_users_only BOOLEAN DEFAULT FALSE,
  first_order_only BOOLEAN DEFAULT FALSE,
  user_ids BIGINT[], -- Specific users only
  
  -- Stacking
  can_combine_with_other_coupons BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (coupon_type IN ('percentage', 'fixed_amount', 'free_shipping', 'buy_one_get_one')),
  CHECK (discount_value > 0),
  CHECK (valid_until > valid_from),
  
  -- Indexes
  INDEX idx_coupons_code (code),
  INDEX idx_coupons_active (is_active),
  INDEX idx_coupons_validity (valid_from, valid_until),
  INDEX idx_coupons_categories USING GIN (applicable_categories),
  INDEX idx_coupons_products USING GIN (applicable_products)
);
```

---

### 3.2 `coupon_usages` Table (Coupon Usage Tracking)

```sql
CREATE TABLE coupon_usages (
  id BIGSERIAL PRIMARY KEY,
  coupon_id BIGINT NOT NULL REFERENCES coupons(id),
  user_id BIGINT NOT NULL REFERENCES users(id),
  order_id BIGINT NOT NULL REFERENCES orders(id),
  
  -- Usage Details
  discount_amount DECIMAL(10, 2) NOT NULL,
  order_amount DECIMAL(10, 2) NOT NULL,
  
  -- Timestamps
  used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_coupon_usages_coupon (coupon_id),
  INDEX idx_coupon_usages_user (user_id),
  INDEX idx_coupon_usages_order (order_id),
  INDEX idx_coupon_usages_used_at (used_at)
);
```

---

### 3.3 `promotions` Table (Flash Sales, Deals)

```sql
CREATE TABLE promotions (
  id BIGSERIAL PRIMARY KEY,
  
  -- Promotion Details
  name VARCHAR(255) NOT NULL,
  description TEXT,
  promotion_type VARCHAR(50) NOT NULL,
  -- Values: flash_sale, daily_deal, seasonal_sale, clearance
  
  -- Discount
  discount_type VARCHAR(50), -- percentage, fixed_amount
  discount_value DECIMAL(10, 2),
  max_discount_amount DECIMAL(10, 2),
  
  -- Validity
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Applicability
  applicable_products BIGINT[],
  applicable_categories BIGINT[],
  applicable_brands BIGINT[],
  applicable_suppliers BIGINT[],
  
  -- Display
  banner_image_url VARCHAR(500),
  display_order INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  
  -- Statistics
  total_orders INTEGER DEFAULT 0,
  total_revenue DECIMAL(12, 2) DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (promotion_type IN ('flash_sale', 'daily_deal', 'seasonal_sale', 'clearance')),
  CHECK (end_time > start_time),
  
  -- Indexes
  INDEX idx_promotions_type (promotion_type),
  INDEX idx_promotions_active (is_active),
  INDEX idx_promotions_time (start_time, end_time),
  INDEX idx_promotions_featured (is_featured)
);
```

---

## 4. REVIEWS & RATINGS

### 4.1 `reviews` Table (Enhanced)

```sql
CREATE TABLE reviews (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id),
  order_item_id BIGINT REFERENCES order_items(id), -- For verified purchase
  
  -- Rating
  rating INTEGER NOT NULL,
  -- CHECK (rating >= 1 AND rating <= 5)
  
  -- Review Content
  title VARCHAR(255),
  comment TEXT,
  
  -- Status
  is_verified_purchase BOOLEAN DEFAULT FALSE,
  is_approved BOOLEAN DEFAULT FALSE, -- Admin moderation
  is_featured BOOLEAN DEFAULT FALSE,
  helpful_count INTEGER DEFAULT 0,
  not_helpful_count INTEGER DEFAULT 0,
  
  -- Images
  review_images JSONB DEFAULT '[]', -- Array of image URLs
  
  -- Moderation
  moderation_status VARCHAR(50) DEFAULT 'pending',
  -- Values: pending, approved, rejected, flagged
  moderated_by_id BIGINT REFERENCES admins(id),
  moderated_at TIMESTAMP,
  moderation_notes TEXT,
  
  -- Response
  supplier_response TEXT,
  supplier_response_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Constraints
  UNIQUE (product_id, user_id), -- One review per user per product
  CHECK (rating >= 1 AND rating <= 5),
  CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'flagged')),
  
  -- Indexes
  INDEX idx_reviews_product (product_id),
  INDEX idx_reviews_user (user_id),
  INDEX idx_reviews_rating (rating),
  INDEX idx_reviews_approved (is_approved),
  INDEX idx_reviews_verified (is_verified_purchase),
  INDEX idx_reviews_moderation (moderation_status),
  INDEX idx_reviews_deleted_at (deleted_at)
);
```

---

### 4.2 `review_helpful_votes` Table

```sql
CREATE TABLE review_helpful_votes (
  id BIGSERIAL PRIMARY KEY,
  review_id BIGINT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Vote
  is_helpful BOOLEAN NOT NULL, -- true = helpful, false = not helpful
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (review_id, user_id), -- One vote per user per review
  
  -- Indexes
  INDEX idx_review_helpful_votes_review (review_id),
  INDEX idx_review_helpful_votes_user (user_id)
);
```

---

## 5. RETURNS & REFUNDS

### 5.1 `return_requests` Table (Enhanced)

```sql
CREATE TABLE return_requests (
  id BIGSERIAL PRIMARY KEY,
  return_id VARCHAR(50) NOT NULL UNIQUE,
  order_id BIGINT NOT NULL REFERENCES orders(id),
  order_item_id BIGINT NOT NULL REFERENCES order_items(id),
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Return Details
  reason VARCHAR(255) NOT NULL,
  -- Values: defective, wrong_item, size_issue, quality_issue, 
  --         not_as_described, changed_mind, other
  description TEXT,
  return_type VARCHAR(50) DEFAULT 'refund',
  -- Values: refund, exchange, replacement
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, approved, rejected, processing, 
  --         pickup_scheduled, picked_up, received, 
  --         refunded, exchanged, replaced, cancelled
  status_updated_at TIMESTAMP,
  status_history JSONB DEFAULT '[]',
  
  -- Resolution
  resolution_type VARCHAR(50), -- refund, exchange, replacement
  resolution_amount DECIMAL(10, 2),
  resolved_by_admin_id BIGINT REFERENCES admins(id),
  resolved_at TIMESTAMP,
  
  -- Refund Information
  refund_id BIGINT REFERENCES payment_refunds(id),
  refund_status VARCHAR(50),
  refund_amount DECIMAL(10, 2),
  refund_transaction_id VARCHAR(255),
  
  -- Pickup/Dropoff
  pickup_address_id BIGINT REFERENCES addresses(id),
  pickup_scheduled_at TIMESTAMP,
  pickup_completed_at TIMESTAMP,
  
  -- Items
  return_quantity INTEGER NOT NULL,
  return_condition VARCHAR(50), -- unused, used, damaged
  
  -- Media
  return_images JSONB DEFAULT '[]', -- Images of returned items
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'approved', 'rejected', 'processing', 
                    'pickup_scheduled', 'picked_up', 'received', 
                    'refunded', 'exchanged', 'replaced', 'cancelled')),
  CHECK (return_quantity > 0),
  
  -- Indexes
  INDEX idx_return_requests_order (order_id),
  INDEX idx_return_requests_user (user_id),
  INDEX idx_return_requests_status (status),
  INDEX idx_return_requests_return_id (return_id)
);
```

---

### 5.2 `return_items` Table (Individual Return Items)

```sql
CREATE TABLE return_items (
  id BIGSERIAL PRIMARY KEY,
  return_request_id BIGINT NOT NULL REFERENCES return_requests(id) ON DELETE CASCADE,
  order_item_id BIGINT NOT NULL REFERENCES order_items(id),
  
  -- Return Details
  quantity INTEGER NOT NULL,
  reason TEXT,
  condition VARCHAR(50), -- unused, used, damaged
  
  -- Media
  images JSONB DEFAULT '[]',
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_return_items_return_request (return_request_id),
  INDEX idx_return_items_order_item (order_item_id)
);
```

---

This is **Chunk 2** covering advanced features. **Chunk 3** will cover:
- Inventory Management & Tracking
- Analytics & Metrics
- Notifications
- Wishlist & Cart enhancements
- Search & Discovery
- Admin Management

Should I continue with Chunk 3?


