# Production Schema Design - Chunk 3: Supporting Features
## Enterprise-Grade E-Commerce Platform (Myntra/Meesho Level)

This document covers **supporting features** that enhance user experience and platform operations.

---

## 📋 Table of Contents

1. Inventory Management & Tracking
2. Analytics & Metrics
3. Notifications System
4. Wishlist & Cart Enhancements
5. Search & Discovery
6. Admin Management
7. Customer Service
8. Loyalty & Rewards

---

## 1. INVENTORY MANAGEMENT & TRACKING

### 1.1 `inventory_transactions` Table (Stock Movement Log)

```sql
CREATE TABLE inventory_transactions (
  id BIGSERIAL PRIMARY KEY,
  transaction_id VARCHAR(100) NOT NULL UNIQUE,
  
  -- Product Information
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id),
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id),
  
  -- Transaction Details
  transaction_type VARCHAR(50) NOT NULL,
  -- Values: purchase, sale, return, adjustment, transfer, damage, expiry
  quantity INTEGER NOT NULL, -- Positive for additions, negative for deductions
  balance_after INTEGER NOT NULL, -- Stock after this transaction
  
  -- Reference
  reference_type VARCHAR(50), -- order, return, adjustment, transfer
  reference_id BIGINT, -- Order ID, Return ID, etc.
  
  -- Details
  reason TEXT,
  notes TEXT,
  
  -- User
  performed_by_id BIGINT REFERENCES users(id),
  performed_by_type VARCHAR(50), -- user, supplier, admin, system
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (transaction_type IN ('purchase', 'sale', 'return', 'adjustment', 'transfer', 'damage', 'expiry')),
  
  -- Indexes
  INDEX idx_inventory_transactions_variant (product_variant_id),
  INDEX idx_inventory_transactions_supplier (supplier_profile_id),
  INDEX idx_inventory_transactions_type (transaction_type),
  INDEX idx_inventory_transactions_reference (reference_type, reference_id),
  INDEX idx_inventory_transactions_created_at (created_at)
);
```

---

### 1.2 `warehouses` Table (Warehouse Management)

```sql
CREATE TABLE warehouses (
  id BIGSERIAL PRIMARY KEY,
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id),
  
  -- Warehouse Details
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(20),
  country VARCHAR(100) DEFAULT 'India',
  
  -- Contact
  contact_person VARCHAR(255),
  contact_phone VARCHAR(20),
  contact_email VARCHAR(255),
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_primary BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (supplier_profile_id, code),
  
  -- Indexes
  INDEX idx_warehouses_supplier (supplier_profile_id),
  INDEX idx_warehouses_active (is_active)
);
```

---

### 1.3 `warehouse_inventory` Table (Stock by Warehouse)

```sql
CREATE TABLE warehouse_inventory (
  id BIGSERIAL PRIMARY KEY,
  warehouse_id BIGINT NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id),
  
  -- Stock
  stock_quantity INTEGER DEFAULT 0 NOT NULL,
  reserved_quantity INTEGER DEFAULT 0,
  available_quantity INTEGER GENERATED ALWAYS AS (stock_quantity - reserved_quantity) STORED,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (warehouse_id, product_variant_id),
  CHECK (stock_quantity >= 0),
  CHECK (reserved_quantity >= 0),
  
  -- Indexes
  INDEX idx_warehouse_inventory_warehouse (warehouse_id),
  INDEX idx_warehouse_inventory_variant (product_variant_id)
);
```

---

## 2. ANALYTICS & METRICS

### 2.1 `product_views` Table (Product View Tracking)

```sql
CREATE TABLE product_views (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id),
  user_id BIGINT REFERENCES users(id), -- NULL for anonymous
  product_variant_id BIGINT REFERENCES product_variants(id),
  
  -- Session
  session_id VARCHAR(255),
  ip_address VARCHAR(50),
  user_agent TEXT,
  
  -- Source
  referrer_url VARCHAR(500),
  source VARCHAR(50), -- search, category, brand, direct, recommendation
  
  -- Timestamps
  viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_product_views_product (product_id),
  INDEX idx_product_views_user (user_id),
  INDEX idx_product_views_viewed_at (viewed_at),
  INDEX idx_product_views_session (session_id)
);
```

---

### 2.2 `user_searches` Table (Search History)

```sql
CREATE TABLE user_searches (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id), -- NULL for anonymous
  session_id VARCHAR(255),
  
  -- Search Details
  search_query VARCHAR(500) NOT NULL,
  filters JSONB DEFAULT '{}', -- Applied filters
  results_count INTEGER,
  
  -- Source
  source VARCHAR(50), -- search_bar, voice, image_search
  
  -- Timestamps
  searched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_user_searches_user (user_id),
  INDEX idx_user_searches_query (search_query),
  INDEX idx_user_searches_searched_at (searched_at),
  INDEX idx_user_searches_session (session_id)
);
```

---

### 2.3 `supplier_analytics` Table (Supplier Dashboard Metrics)

```sql
CREATE TABLE supplier_analytics (
  id BIGSERIAL PRIMARY KEY,
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id),
  
  -- Date
  date DATE NOT NULL,
  
  -- Sales Metrics
  total_orders INTEGER DEFAULT 0,
  total_revenue DECIMAL(12, 2) DEFAULT 0,
  total_items_sold INTEGER DEFAULT 0,
  
  -- Product Metrics
  products_viewed INTEGER DEFAULT 0,
  products_added_to_cart INTEGER DEFAULT 0,
  conversion_rate DECIMAL(5, 2) DEFAULT 0,
  
  -- Customer Metrics
  new_customers INTEGER DEFAULT 0,
  returning_customers INTEGER DEFAULT 0,
  
  -- Ratings
  average_rating DECIMAL(3, 2) DEFAULT 0,
  new_reviews_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (supplier_profile_id, date),
  
  -- Indexes
  INDEX idx_supplier_analytics_supplier (supplier_profile_id),
  INDEX idx_supplier_analytics_date (date)
);
```

---

## 3. NOTIFICATIONS SYSTEM

### 3.1 `notifications` Table (User Notifications)

```sql
CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Notification Details
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  -- Values: order_update, payment, promotion, review, system, shipping
  
  -- Data
  data JSONB DEFAULT '{}', -- Additional data (order_id, product_id, etc.)
  
  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  
  -- Delivery
  sent_email BOOLEAN DEFAULT FALSE,
  sent_sms BOOLEAN DEFAULT FALSE,
  sent_push BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_notifications_user (user_id),
  INDEX idx_notifications_read (is_read),
  INDEX idx_notifications_type (notification_type),
  INDEX idx_notifications_created_at (created_at)
);
```

---

### 3.2 `notification_preferences` Table

```sql
CREATE TABLE notification_preferences (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Preferences (JSONB for flexibility)
  preferences JSONB DEFAULT '{
    "email": {
      "order_updates": true,
      "promotions": true,
      "reviews": true,
      "system": true
    },
    "sms": {
      "order_updates": true,
      "promotions": false,
      "reviews": false,
      "system": false
    },
    "push": {
      "order_updates": true,
      "promotions": true,
      "reviews": true,
      "system": true
    }
  }',
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_notification_preferences_user (user_id)
);
```

---

## 4. WISHLIST & CART ENHANCEMENTS

### 4.1 `wishlists` Table (Enhanced)

```sql
CREATE TABLE wishlists (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Wishlist Details
  name VARCHAR(255) DEFAULT 'My Wishlist',
  description TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  is_default BOOLEAN DEFAULT FALSE,
  
  -- Sharing
  share_token VARCHAR(255) UNIQUE,
  share_enabled BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Indexes
  INDEX idx_wishlists_user (user_id),
  INDEX idx_wishlists_deleted_at (deleted_at),
  INDEX idx_wishlists_share_token (share_token)
);
```

---

### 4.2 `wishlist_items` Table (Enhanced)

```sql
CREATE TABLE wishlist_items (
  id BIGSERIAL PRIMARY KEY,
  wishlist_id BIGINT NOT NULL REFERENCES wishlists(id) ON DELETE CASCADE,
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id),
  
  -- Notes
  notes TEXT,
  priority INTEGER DEFAULT 0,
  
  -- Price Tracking
  price_when_added DECIMAL(10, 2),
  current_price DECIMAL(10, 2),
  price_drop_notified BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Constraints
  UNIQUE (wishlist_id, product_variant_id), -- One item per wishlist
  
  -- Indexes
  INDEX idx_wishlist_items_wishlist (wishlist_id),
  INDEX idx_wishlist_items_variant (product_variant_id),
  INDEX idx_wishlist_items_deleted_at (deleted_at)
);
```

---

### 4.3 `cart_items` Table (Enhanced)

```sql
CREATE TABLE cart_items (
  id BIGSERIAL PRIMARY KEY,
  cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id),
  
  -- Quantity
  quantity INTEGER NOT NULL DEFAULT 1,
  
  -- Price Snapshot (when added to cart)
  price_when_added DECIMAL(10, 2),
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Constraints
  CHECK (quantity > 0),
  
  -- Indexes
  INDEX idx_cart_items_cart (cart_id),
  INDEX idx_cart_items_variant (product_variant_id),
  INDEX idx_cart_items_deleted_at (deleted_at)
);
```

---

## 5. SEARCH & DISCOVERY

### 5.1 `search_suggestions` Table (Auto-complete Suggestions)

```sql
CREATE TABLE search_suggestions (
  id BIGSERIAL PRIMARY KEY,
  
  -- Suggestion
  query VARCHAR(500) NOT NULL,
  suggestion_type VARCHAR(50) NOT NULL,
  -- Values: product, category, brand, trending
  
  -- Reference
  reference_id BIGINT, -- Product ID, Category ID, etc.
  reference_type VARCHAR(50),
  
  -- Popularity
  search_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  
  -- Display
  display_text VARCHAR(500),
  image_url VARCHAR(500),
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_search_suggestions_query (query),
  INDEX idx_search_suggestions_type (suggestion_type),
  INDEX idx_search_suggestions_active (is_active),
  INDEX idx_search_suggestions_popularity (search_count)
);
```

---

### 5.2 `trending_products` Table

```sql
CREATE TABLE trending_products (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id),
  
  -- Metrics (cached)
  views_24h INTEGER DEFAULT 0,
  orders_24h INTEGER DEFAULT 0,
  revenue_24h DECIMAL(12, 2) DEFAULT 0,
  trend_score DECIMAL(10, 2) DEFAULT 0,
  
  -- Category Trending
  category_id BIGINT REFERENCES categories(id),
  rank_in_category INTEGER,
  
  -- Timestamps
  calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (product_id, calculated_at::DATE), -- One entry per product per day
  
  -- Indexes
  INDEX idx_trending_products_product (product_id),
  INDEX idx_trending_products_score (trend_score),
  INDEX idx_trending_products_category (category_id),
  INDEX idx_trending_products_calculated_at (calculated_at)
);
```

---

## 6. ADMIN MANAGEMENT

### 6.1 `admins` Table (Enhanced)

```sql
CREATE TABLE admins (
  id BIGSERIAL PRIMARY KEY,
  
  -- Basic Information
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20) UNIQUE,
  password_digest VARCHAR(255) NOT NULL,
  
  -- Role
  role VARCHAR(50) NOT NULL,
  -- Values: super_admin, product_admin, order_admin, support_admin, 
  --         finance_admin, marketing_admin
  
  -- Status
  email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_blocked BOOLEAN DEFAULT FALSE,
  last_login_at TIMESTAMP,
  
  -- Authentication
  temp_password_digest VARCHAR(255),
  temp_password_expires_at TIMESTAMP,
  password_reset_required BOOLEAN DEFAULT FALSE,
  password_changed_at TIMESTAMP,
  
  -- Permissions (JSONB for flexibility)
  permissions JSONB DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Constraints
  CHECK (role IN ('super_admin', 'product_admin', 'order_admin', 'support_admin', 
                  'finance_admin', 'marketing_admin')),
  
  -- Indexes
  INDEX idx_admins_email (email),
  INDEX idx_admins_role (role),
  INDEX idx_admins_active (is_active),
  INDEX idx_admins_deleted_at (deleted_at)
);
```

---

### 6.2 `admin_activities` Table (Admin Action Log)

```sql
CREATE TABLE admin_activities (
  id BIGSERIAL PRIMARY KEY,
  admin_id BIGINT NOT NULL REFERENCES admins(id),
  
  -- Activity Details
  action VARCHAR(100) NOT NULL, -- create_product, approve_order, etc.
  resource_type VARCHAR(50), -- product, order, supplier, etc.
  resource_id BIGINT,
  
  -- Details
  description TEXT,
  changes JSONB DEFAULT '{}', -- Before/after changes
  ip_address VARCHAR(50),
  user_agent TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_admin_activities_admin (admin_id),
  INDEX idx_admin_activities_resource (resource_type, resource_id),
  INDEX idx_admin_activities_action (action),
  INDEX idx_admin_activities_created_at (created_at)
);
```

---

## 7. CUSTOMER SERVICE

### 7.1 `support_tickets` Table

```sql
CREATE TABLE support_tickets (
  id BIGSERIAL PRIMARY KEY,
  ticket_id VARCHAR(50) NOT NULL UNIQUE,
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Ticket Details
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(50) NOT NULL,
  -- Values: order_issue, product_issue, payment_issue, account_issue, other
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'open',
  -- Values: open, in_progress, waiting_customer, resolved, closed
  priority VARCHAR(50) DEFAULT 'medium',
  -- Values: low, medium, high, urgent
  
  -- Assignment
  assigned_to_id BIGINT REFERENCES admins(id),
  assigned_at TIMESTAMP,
  
  -- Resolution
  resolution TEXT,
  resolved_by_id BIGINT REFERENCES admins(id),
  resolved_at TIMESTAMP,
  
  -- Related Resources
  order_id BIGINT REFERENCES orders(id),
  product_id BIGINT REFERENCES products(id),
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('open', 'in_progress', 'waiting_customer', 'resolved', 'closed')),
  CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  
  -- Indexes
  INDEX idx_support_tickets_user (user_id),
  INDEX idx_support_tickets_status (status),
  INDEX idx_support_tickets_assigned (assigned_to_id),
  INDEX idx_support_tickets_ticket_id (ticket_id),
  INDEX idx_support_tickets_created_at (created_at)
);
```

---

### 7.2 `support_ticket_messages` Table

```sql
CREATE TABLE support_ticket_messages (
  id BIGSERIAL PRIMARY KEY,
  ticket_id BIGINT NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  
  -- Message
  message TEXT NOT NULL,
  sender_type VARCHAR(50) NOT NULL, -- user, admin
  sender_id BIGINT NOT NULL, -- User ID or Admin ID
  
  -- Attachments
  attachments JSONB DEFAULT '[]', -- Array of file URLs
  
  -- Status
  is_internal BOOLEAN DEFAULT FALSE, -- Internal notes not visible to user
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_support_ticket_messages_ticket (ticket_id),
  INDEX idx_support_ticket_messages_sender (sender_type, sender_id),
  INDEX idx_support_ticket_messages_created_at (created_at)
);
```

---

## 8. LOYALTY & REWARDS

### 8.1 `loyalty_points_transactions` Table

```sql
CREATE TABLE loyalty_points_transactions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Transaction Details
  transaction_type VARCHAR(50) NOT NULL,
  -- Values: earned, redeemed, expired, adjusted
  points INTEGER NOT NULL, -- Positive for earned, negative for redeemed
  balance_after INTEGER NOT NULL,
  
  -- Reference
  reference_type VARCHAR(50), -- order, referral, promotion, adjustment
  reference_id BIGINT,
  
  -- Details
  description TEXT,
  expiry_date DATE, -- For earned points
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (transaction_type IN ('earned', 'redeemed', 'expired', 'adjusted')),
  
  -- Indexes
  INDEX idx_loyalty_points_transactions_user (user_id),
  INDEX idx_loyalty_points_transactions_type (transaction_type),
  INDEX idx_loyalty_points_transactions_reference (reference_type, reference_id),
  INDEX idx_loyalty_points_transactions_created_at (created_at)
);
```

---

### 8.2 `referrals` Table (Referral Tracking)

```sql
CREATE TABLE referrals (
  id BIGSERIAL PRIMARY KEY,
  referrer_id BIGINT NOT NULL REFERENCES users(id),
  referred_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Referral Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, completed, rewarded
  completed_at TIMESTAMP,
  
  -- Rewards
  referrer_reward_points INTEGER DEFAULT 0,
  referred_reward_points INTEGER DEFAULT 0,
  referrer_reward_paid BOOLEAN DEFAULT FALSE,
  referred_reward_paid BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (referrer_id, referred_id),
  CHECK (status IN ('pending', 'completed', 'rewarded')),
  
  -- Indexes
  INDEX idx_referrals_referrer (referrer_id),
  INDEX idx_referrals_referred (referred_id),
  INDEX idx_referrals_status (status)
);
```

---

## 9. ADDITIONAL SUPPORTING TABLES

### 9.1 `email_verifications` Table (Enhanced)

```sql
CREATE TABLE email_verifications (
  id BIGSERIAL PRIMARY KEY,
  
  email VARCHAR(255) NOT NULL,
  otp VARCHAR(10) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  
  -- Polymorphic (can verify User, Supplier, Admin)
  verifiable_type VARCHAR(50),
  verifiable_id BIGINT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_email_verifications_email (email),
  INDEX idx_email_verifications_verifiable (verifiable_type, verifiable_id),
  INDEX idx_email_verifications_expires_at (expires_at)
);
```

---

### 9.2 `pincode_serviceability` Table (Delivery Area Mapping)

```sql
CREATE TABLE pincode_serviceability (
  id BIGSERIAL PRIMARY KEY,
  pincode VARCHAR(20) NOT NULL,
  
  -- Serviceability
  is_serviceable BOOLEAN DEFAULT TRUE,
  is_cod_available BOOLEAN DEFAULT FALSE,
  
  -- Location
  city VARCHAR(100),
  state VARCHAR(100),
  district VARCHAR(100),
  zone VARCHAR(50),
  
  -- Delivery Time
  standard_delivery_days INTEGER,
  express_delivery_days INTEGER,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (pincode),
  
  -- Indexes
  INDEX idx_pincode_serviceability_pincode (pincode),
  INDEX idx_pincode_serviceability_city (city),
  INDEX idx_pincode_serviceability_state (state)
);
```

---

### 9.3 `audit_logs` Table (System-Wide Audit Trail)

```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  
  -- Entity
  auditable_type VARCHAR(50) NOT NULL,
  auditable_id BIGINT NOT NULL,
  
  -- Action
  action VARCHAR(50) NOT NULL, -- create, update, delete
  changes JSONB DEFAULT '{}', -- Before/after changes
  
  -- User
  user_id BIGINT REFERENCES users(id),
  user_type VARCHAR(50), -- user, admin, supplier
  ip_address VARCHAR(50),
  user_agent TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_audit_logs_auditable (auditable_type, auditable_id),
  INDEX idx_audit_logs_user (user_id),
  INDEX idx_audit_logs_action (action),
  INDEX idx_audit_logs_created_at (created_at)
);
```

---

## 📊 Complete Table Count Summary

### Core Foundation (Chunk 1): 15 tables
- Users, Addresses, Supplier Profiles, Supplier Account Users
- Categories, Brands, Products, Product Variants, Attributes, Images
- Orders, Order Items

### Advanced Features (Chunk 2): 12 tables
- Payments, Payment Refunds, Supplier Payments, Payment Transactions
- Shipping Methods, Shipments, Shipment Tracking
- Coupons, Coupon Usages, Promotions
- Reviews, Review Helpful Votes
- Return Requests, Return Items

### Supporting Features (Chunk 3): 20 tables
- Inventory Transactions, Warehouses, Warehouse Inventory
- Product Views, User Searches, Supplier Analytics
- Notifications, Notification Preferences
- Wishlists, Wishlist Items, Cart Items
- Search Suggestions, Trending Products
- Admins, Admin Activities
- Support Tickets, Support Ticket Messages
- Loyalty Points, Referrals
- Email Verifications, Pincode Serviceability, Audit Logs

**Total: ~47 core tables** (excluding ActiveStorage, Versions, and other Rails-generated tables)

---

This completes all three chunks of the production schema design. Next, we'll create the step-by-step implementation plan.


