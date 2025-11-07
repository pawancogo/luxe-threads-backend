# Production Schema Design - Chunk 1: Core Foundation
## Enterprise-Grade E-Commerce Platform (Myntra/Meesho Level)

This document covers the **core foundational schema** that every e-commerce platform needs.

---

## 📋 Table of Contents

1. User Management System
2. Supplier Management System
3. Product Catalog System
4. Order Management System
5. Inventory Management

---

## 1. USER MANAGEMENT SYSTEM

### 1.1 `users` Table (Unified User Model)

```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  
  -- Basic Information
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20) UNIQUE,
  alternate_phone VARCHAR(20),
  
  -- Authentication
  password_digest VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  temp_password_digest VARCHAR(255),
  temp_password_expires_at TIMESTAMP,
  password_reset_required BOOLEAN DEFAULT FALSE,
  password_changed_at TIMESTAMP,
  
  -- Platform Role (determines access level)
  role VARCHAR(50) NOT NULL,
  -- Values: 
  --   customer, premium_customer, vip_customer (Customer tiers)
  --   supplier (Supplier role - can access supplier dashboard)
  --   super_admin, product_admin, order_admin, support_admin (Admin roles)
  
  -- Customer Profile Information
  date_of_birth DATE,
  gender VARCHAR(20), -- male, female, other, prefer_not_to_say
  profile_image_url VARCHAR(500),
  
  -- Referral & Loyalty
  referral_code VARCHAR(50) UNIQUE,
  referred_by_id BIGINT REFERENCES users(id),
  loyalty_points INTEGER DEFAULT 0,
  total_loyalty_points_earned INTEGER DEFAULT 0,
  
  -- Preferences
  preferred_language VARCHAR(10) DEFAULT 'en',
  preferred_currency VARCHAR(10) DEFAULT 'INR',
  timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
  notification_preferences JSONB DEFAULT '{"email": true, "sms": true, "push": true}',
  
  -- Account Status
  is_active BOOLEAN DEFAULT TRUE,
  is_blocked BOOLEAN DEFAULT FALSE,
  blocked_reason TEXT,
  blocked_at TIMESTAMP,
  last_login_at TIMESTAMP,
  last_active_at TIMESTAMP,
  
  -- Social Login (optional)
  google_id VARCHAR(255),
  facebook_id VARCHAR(255),
  apple_id VARCHAR(255),
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP, -- Soft delete
  
  -- Constraints
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
  CHECK (role IN ('customer', 'premium_customer', 'vip_customer', 'supplier', 
                  'super_admin', 'product_admin', 'order_admin', 'support_admin')),
  
  -- Indexes
  INDEX idx_users_email (email),
  INDEX idx_users_phone (phone_number),
  INDEX idx_users_role (role),
  INDEX idx_users_deleted_at (deleted_at),
  INDEX idx_users_referred_by (referred_by_id),
  INDEX idx_users_referral_code (referral_code),
  INDEX idx_users_active (is_active),
  INDEX idx_users_last_active (last_active_at)
);
```

**Key Features:**
- ✅ Single authentication table for all user types
- ✅ Soft delete support
- ✅ Referral system
- ✅ Loyalty points tracking
- ✅ Social login support
- ✅ Multi-language/currency support
- ✅ Activity tracking

---

### 1.2 `addresses` Table (Enhanced)

```sql
CREATE TABLE addresses (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Address Type
  address_type VARCHAR(50) NOT NULL, -- home, work, other
  label VARCHAR(100), -- "My Home", "Office", "Gift Address"
  
  -- Recipient Information
  full_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  alternate_phone VARCHAR(20),
  
  -- Address Details
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  landmark VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20) NOT NULL,
  country VARCHAR(100) NOT NULL DEFAULT 'India',
  
  -- Location Data (for delivery optimization)
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  pincode_id BIGINT, -- Reference to pincode service area
  
  -- Address Quality
  is_verified BOOLEAN DEFAULT FALSE,
  verification_status VARCHAR(50), -- pending, verified, failed
  
  -- Default Flags
  is_default_shipping BOOLEAN DEFAULT FALSE,
  is_default_billing BOOLEAN DEFAULT FALSE,
  
  -- Delivery Instructions
  delivery_instructions TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,
  
  -- Indexes
  INDEX idx_addresses_user (user_id),
  INDEX idx_addresses_type (address_type),
  INDEX idx_addresses_deleted_at (deleted_at),
  INDEX idx_addresses_pincode (postal_code),
  INDEX idx_addresses_location (latitude, longitude)
);
```

---

### 1.3 `supplier_profiles` Table (Enhanced for Multi-User)

```sql
CREATE TABLE supplier_profiles (
  id BIGSERIAL PRIMARY KEY,
  
  -- Primary Owner (the user who created the supplier account)
  owner_user_id BIGINT NOT NULL REFERENCES users(id),
  -- Legacy field for backward compatibility
  user_id BIGINT REFERENCES users(id),
  
  -- Company Information
  company_name VARCHAR(255) NOT NULL,
  company_registration_number VARCHAR(100) UNIQUE,
  gst_number VARCHAR(50) NOT NULL UNIQUE,
  pan_number VARCHAR(20),
  cin_number VARCHAR(50), -- Company Identification Number
  
  -- Business Details
  business_type VARCHAR(50), -- manufacturer, wholesaler, retailer, distributor, exporter
  business_category VARCHAR(100), -- fashion, electronics, home, etc.
  description TEXT,
  website_url VARCHAR(500),
  logo_url VARCHAR(500),
  
  -- Address Information
  registered_address TEXT NOT NULL,
  warehouse_addresses JSONB DEFAULT '[]', -- Array of warehouse addresses
  -- Format: [{"name": "Main Warehouse", "address": "...", "pincode": "..."}]
  
  -- Contact Information
  contact_email VARCHAR(255),
  contact_phone VARCHAR(20),
  support_email VARCHAR(255),
  support_phone VARCHAR(20),
  
  -- Verification & Status
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  verified_by_admin_id BIGINT REFERENCES admins(id),
  verification_documents JSONB DEFAULT '[]', -- Store document URLs
  
  -- Supplier Tier/Subscription
  supplier_tier VARCHAR(50) DEFAULT 'basic',
  -- Values: basic, verified, premium, partner
  -- Controls: commission rates, features, limits
  tier_upgraded_at TIMESTAMP,
  
  -- Multi-User Settings
  max_users INTEGER DEFAULT 1,
  allow_invites BOOLEAN DEFAULT FALSE,
  invite_code VARCHAR(50) UNIQUE,
  
  -- Business Metrics (cached for performance)
  total_products_count INTEGER DEFAULT 0,
  active_products_count INTEGER DEFAULT 0,
  total_orders_count INTEGER DEFAULT 0,
  total_revenue DECIMAL(12, 2) DEFAULT 0,
  average_rating DECIMAL(3, 2),
  total_reviews_count INTEGER DEFAULT 0,
  
  -- Payment & Commission
  bank_account_number VARCHAR(50),
  bank_ifsc_code VARCHAR(20),
  bank_name VARCHAR(255),
  bank_branch VARCHAR(255),
  account_holder_name VARCHAR(255),
  upi_id VARCHAR(255),
  commission_rate DECIMAL(5, 2) DEFAULT 10.00, -- Percentage
  payment_cycle VARCHAR(50) DEFAULT 'weekly', -- daily, weekly, biweekly, monthly
  
  -- Settings
  auto_fulfill_orders BOOLEAN DEFAULT FALSE,
  minimum_order_amount DECIMAL(10, 2),
  return_policy_days INTEGER DEFAULT 7,
  shipping_policy TEXT,
  
  -- Operational Settings
  handling_time_days INTEGER DEFAULT 1, -- Days to prepare order
  shipping_zones JSONB DEFAULT '{}', -- Zones where supplier ships
  free_shipping_above DECIMAL(10, 2), -- Free shipping threshold
  
  -- Account Status
  is_active BOOLEAN DEFAULT TRUE,
  is_suspended BOOLEAN DEFAULT FALSE,
  suspended_reason TEXT,
  suspended_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (max_users >= 1),
  CHECK (supplier_tier IN ('basic', 'verified', 'premium', 'partner')),
  CHECK (commission_rate >= 0 AND commission_rate <= 100),
  
  -- Indexes
  INDEX idx_supplier_profiles_owner (owner_user_id),
  INDEX idx_supplier_profiles_user_id (user_id),
  INDEX idx_supplier_profiles_verified (verified),
  INDEX idx_supplier_profiles_tier (supplier_tier),
  INDEX idx_supplier_profiles_gst (gst_number),
  INDEX idx_supplier_profiles_active (is_active)
);
```

---

### 1.4 `supplier_account_users` Table (Multi-User Support)

```sql
CREATE TABLE supplier_account_users (
  id BIGSERIAL PRIMARY KEY,
  
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Supplier Account Role (different from platform role)
  role VARCHAR(50) NOT NULL,
  -- Values: owner, admin, product_manager, order_manager, accountant, staff
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  -- Values: active, inactive, suspended, pending_invitation
  
  -- Invitation
  invited_by_user_id BIGINT REFERENCES users(id),
  invited_at TIMESTAMP,
  invitation_token VARCHAR(255) UNIQUE,
  invitation_expires_at TIMESTAMP,
  accepted_at TIMESTAMP,
  
  -- Access Control (permissions)
  can_manage_products BOOLEAN DEFAULT FALSE,
  can_manage_orders BOOLEAN DEFAULT FALSE,
  can_view_financials BOOLEAN DEFAULT FALSE,
  can_manage_users BOOLEAN DEFAULT FALSE,
  can_manage_settings BOOLEAN DEFAULT FALSE,
  can_view_analytics BOOLEAN DEFAULT FALSE,
  
  -- Custom Permissions (JSONB for flexibility)
  custom_permissions JSONB DEFAULT '{}',
  
  -- Activity Tracking
  last_active_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (supplier_profile_id, user_id),
  CHECK (status IN ('active', 'inactive', 'suspended', 'pending_invitation')),
  CHECK (role IN ('owner', 'admin', 'product_manager', 'order_manager', 'accountant', 'staff')),
  
  -- Indexes
  INDEX idx_supplier_account_users_supplier (supplier_profile_id),
  INDEX idx_supplier_account_users_user (user_id),
  INDEX idx_supplier_account_users_role (role),
  INDEX idx_supplier_account_users_status (status),
  INDEX idx_supplier_account_users_token (invitation_token)
);
```

---

## 2. PRODUCT CATALOG SYSTEM

### 2.1 `categories` Table (Hierarchical Categories)

```sql
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  
  -- Hierarchy
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  parent_id BIGINT REFERENCES categories(id),
  level INTEGER DEFAULT 0, -- 0=root, 1=level1, 2=level2, etc.
  sort_order INTEGER DEFAULT 0,
  path VARCHAR(500), -- Full path like "Fashion/Men/T-Shirts"
  
  -- Display
  description TEXT,
  short_description VARCHAR(500),
  image_url VARCHAR(500),
  banner_url VARCHAR(500),
  icon_url VARCHAR(500),
  meta_title VARCHAR(255),
  meta_description TEXT,
  meta_keywords TEXT,
  
  -- Status
  active BOOLEAN DEFAULT TRUE,
  featured BOOLEAN DEFAULT FALSE,
  
  -- Statistics (cached)
  products_count INTEGER DEFAULT 0,
  active_products_count INTEGER DEFAULT 0,
  
  -- Settings
  require_brand BOOLEAN DEFAULT FALSE,
  require_attributes JSONB DEFAULT '[]', -- Required attribute types for this category
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_categories_parent_id (parent_id),
  INDEX idx_categories_slug (slug),
  INDEX idx_categories_active (active),
  INDEX idx_categories_level (level),
  INDEX idx_categories_path (path)
);
```

---

### 2.2 `brands` Table

```sql
CREATE TABLE brands (
  id BIGSERIAL PRIMARY KEY,
  
  name VARCHAR(255) NOT NULL UNIQUE,
  slug VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  short_description VARCHAR(500),
  logo_url VARCHAR(500),
  banner_url VARCHAR(500),
  
  -- Status
  verified BOOLEAN DEFAULT FALSE,
  featured BOOLEAN DEFAULT FALSE,
  active BOOLEAN DEFAULT TRUE,
  
  -- Brand Information
  country_of_origin VARCHAR(100),
  founded_year INTEGER,
  website_url VARCHAR(500),
  
  -- Statistics
  products_count INTEGER DEFAULT 0,
  active_products_count INTEGER DEFAULT 0,
  
  -- SEO
  meta_title VARCHAR(255),
  meta_description TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_brands_slug (slug),
  INDEX idx_brands_verified (verified),
  INDEX idx_brands_active (active)
);
```

---

### 2.3 `products` Table (Core Product Master)

```sql
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  
  -- Ownership
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id) ON DELETE CASCADE,
  
  -- Classification
  category_id BIGINT NOT NULL REFERENCES categories(id),
  brand_id BIGINT REFERENCES brands(id),
  sub_category VARCHAR(255),
  
  -- Basic Information
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  short_description VARCHAR(500),
  description TEXT NOT NULL,
  highlights TEXT[], -- Array of key highlights
  
  -- Product Type (determines which attributes are applicable)
  product_type VARCHAR(100) NOT NULL,
  -- Examples: 'clothing', 'electronics', 'accessories', 'footwear', 'home_decor'
  
  -- Status & Lifecycle
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, active, inactive, rejected, archived, out_of_stock
  status_changed_at TIMESTAMP,
  status_changed_by_id BIGINT REFERENCES users(id),
  
  -- Admin Verification
  verified_by_admin_id BIGINT REFERENCES admins(id),
  verified_at TIMESTAMP,
  rejection_reason TEXT,
  
  -- SEO & Discovery
  meta_title VARCHAR(255),
  meta_description TEXT,
  meta_keywords TEXT,
  search_keywords TEXT[], -- Array for flexible search
  tags TEXT[], -- Array of tags for categorization
  
  -- Product-Specific Attributes (JSONB for flexibility)
  product_attributes JSONB DEFAULT '{}',
  -- Example for clothing: {"fabric": "cotton", "care_instructions": "machine wash"}
  -- Example for electronics: {"warranty": "1 year", "included_accessories": ["charger", "manual"]}
  
  -- Pricing (base prices, variants have specific prices)
  base_price DECIMAL(10, 2),
  base_discounted_price DECIMAL(10, 2),
  base_mrp DECIMAL(10, 2), -- Maximum Retail Price
  
  -- Dimensions (for shipping calculations - average)
  length_cm DECIMAL(8, 2),
  width_cm DECIMAL(8, 2),
  height_cm DECIMAL(8, 2),
  weight_kg DECIMAL(8, 3),
  
  -- Ratings & Reviews (cached)
  average_rating DECIMAL(3, 2) DEFAULT 0,
  total_reviews_count INTEGER DEFAULT 0,
  total_ratings_count INTEGER DEFAULT 0,
  rating_distribution JSONB DEFAULT '{"5": 0, "4": 0, "3": 0, "2": 0, "1": 0}',
  
  -- Sales Metrics (cached)
  total_sold_quantity INTEGER DEFAULT 0,
  total_views_count INTEGER DEFAULT 0,
  total_clicks_count INTEGER DEFAULT 0,
  conversion_rate DECIMAL(5, 2) DEFAULT 0,
  
  -- Inventory Summary (cached)
  total_stock_quantity INTEGER DEFAULT 0,
  low_stock_variants_count INTEGER DEFAULT 0,
  
  -- Flags
  is_featured BOOLEAN DEFAULT FALSE,
  is_bestseller BOOLEAN DEFAULT FALSE,
  is_new_arrival BOOLEAN DEFAULT FALSE,
  is_trending BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  published_at TIMESTAMP,
  deleted_at TIMESTAMP, -- Soft delete
  
  -- Constraints
  UNIQUE (supplier_profile_id, slug), -- Unique slug per supplier
  CHECK (status IN ('pending', 'active', 'inactive', 'rejected', 'archived', 'out_of_stock')),
  CHECK (average_rating >= 0 AND average_rating <= 5),
  
  -- Indexes
  INDEX idx_products_supplier (supplier_profile_id),
  INDEX idx_products_category (category_id),
  INDEX idx_products_brand (brand_id),
  INDEX idx_products_status (status),
  INDEX idx_products_slug (slug),
  INDEX idx_products_type (product_type),
  INDEX idx_products_deleted_at (deleted_at),
  INDEX idx_products_search_keywords USING GIN (search_keywords),
  INDEX idx_products_tags USING GIN (tags),
  INDEX idx_products_attributes USING GIN (product_attributes),
  INDEX idx_products_featured (is_featured),
  INDEX idx_products_bestseller (is_bestseller),
  INDEX idx_products_rating (average_rating),
  INDEX idx_products_created_at (created_at)
);
```

---

### 2.4 `product_variants` Table (Variant Management)

```sql
CREATE_TABLE product_variants (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  
  -- Identification
  sku VARCHAR(100) NOT NULL UNIQUE,
  -- Format: SUPPLIER_CODE-PRODUCT_ID-VARIANT_ID
  barcode VARCHAR(100),
  ean_code VARCHAR(100), -- European Article Number
  isbn VARCHAR(50), -- For books
  
  -- Pricing
  price DECIMAL(10, 2) NOT NULL,
  discounted_price DECIMAL(10, 2),
  cost_price DECIMAL(10, 2), -- For supplier's reference
  mrp DECIMAL(10, 2), -- Maximum Retail Price
  currency VARCHAR(10) DEFAULT 'INR',
  
  -- Inventory
  stock_quantity INTEGER DEFAULT 0 NOT NULL,
  reserved_quantity INTEGER DEFAULT 0, -- Reserved for pending orders
  available_quantity INTEGER GENERATED ALWAYS AS (stock_quantity - reserved_quantity) STORED,
  
  -- Low stock alerts
  low_stock_threshold INTEGER DEFAULT 10,
  is_low_stock BOOLEAN GENERATED ALWAYS AS (stock_quantity <= low_stock_threshold) STORED,
  out_of_stock BOOLEAN GENERATED ALWAYS AS (stock_quantity = 0) STORED,
  
  -- Physical Properties
  weight_kg DECIMAL(8, 3),
  length_cm DECIMAL(8, 2),
  width_cm DECIMAL(8, 2),
  height_cm DECIMAL(8, 2),
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_available BOOLEAN GENERATED ALWAYS AS (stock_quantity > 0 AND is_active) STORED,
  
  -- Variant-Specific Attributes (JSONB for flexibility)
  variant_attributes JSONB DEFAULT '{}',
  -- Example: {"color": "Red", "size": "L", "material": "Cotton"}
  
  -- Images (references to product_images table)
  primary_image_id BIGINT,
  
  -- Sales Metrics
  total_sold INTEGER DEFAULT 0,
  total_returned INTEGER DEFAULT 0,
  total_refunded INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (price > 0),
  CHECK (stock_quantity >= 0),
  CHECK (reserved_quantity >= 0),
  
  -- Indexes
  INDEX idx_product_variants_product (product_id),
  INDEX idx_product_variants_sku (sku),
  INDEX idx_product_variants_stock (stock_quantity),
  INDEX idx_product_variants_available (is_available),
  INDEX idx_product_variants_price (price),
  INDEX idx_product_variants_active (is_active),
  INDEX idx_product_variants_low_stock (is_low_stock),
  INDEX idx_product_variants_attributes USING GIN (variant_attributes)
);
```

---

### 2.5 `attribute_types` Table (Flexible Attribute System)

```sql
CREATE TABLE attribute_types (
  id BIGSERIAL PRIMARY KEY,
  
  name VARCHAR(100) NOT NULL UNIQUE,
  -- Examples: 'Color', 'Size', 'Fabric', 'Screen Size', 'RAM', 'Storage', 'Material'
  
  display_name VARCHAR(100),
  data_type VARCHAR(50) DEFAULT 'string',
  -- Values: string, integer, decimal, boolean, json
  
  is_filterable BOOLEAN DEFAULT TRUE, -- Can be used in filters
  is_searchable BOOLEAN DEFAULT FALSE, -- Included in search
  is_required BOOLEAN DEFAULT FALSE, -- Must have a value
  is_variant_attribute BOOLEAN DEFAULT TRUE, -- Belongs to variant (vs product)
  
  applicable_product_types VARCHAR(100)[] DEFAULT '{}',
  -- Array of product types this attribute applies to
  
  applicable_categories BIGINT[] DEFAULT '{}',
  -- Array of category IDs this attribute applies to
  
  sort_order INTEGER DEFAULT 0,
  description TEXT,
  
  -- UI Configuration
  display_type VARCHAR(50) DEFAULT 'dropdown', -- dropdown, radio, checkbox, text, color_picker
  validation_rules JSONB DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_attribute_types_name (name),
  INDEX idx_attribute_types_product_types USING GIN (applicable_product_types),
  INDEX idx_attribute_types_categories USING GIN (applicable_categories)
);
```

---

### 2.6 `attribute_values` Table

```sql
CREATE TABLE attribute_values (
  id BIGSERIAL PRIMARY KEY,
  attribute_type_id BIGINT NOT NULL REFERENCES attribute_types(id) ON DELETE CASCADE,
  
  value VARCHAR(255) NOT NULL,
  display_value VARCHAR(255), -- For display (e.g., "5.5 inch" vs stored "5.5")
  display_order INTEGER DEFAULT 0,
  
  -- Additional metadata (JSONB)
  metadata JSONB DEFAULT '{}',
  -- For Color: {"hex_code": "#FF0000", "rgb": [255,0,0], "image_url": "..."}
  -- For Size: {"order": 5, "size_chart_url": "..."}
  -- For Storage: {"value_gb": 128}
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (attribute_type_id, value),
  
  -- Indexes
  INDEX idx_attribute_values_type (attribute_type_id),
  INDEX idx_attribute_values_value (value),
  INDEX idx_attribute_values_metadata USING GIN (metadata)
);
```

---

### 2.7 `product_variant_attributes` Table (Variant-Attribute Relationships)

```sql
CREATE TABLE product_variant_attributes (
  id BIGSERIAL PRIMARY KEY,
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  attribute_value_id BIGINT NOT NULL REFERENCES attribute_values(id) ON DELETE CASCADE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  UNIQUE (product_variant_id, attribute_value_id),
  
  -- Indexes
  INDEX idx_pva_variant (product_variant_id),
  INDEX idx_pva_attribute_value (attribute_value_id)
);
```

---

### 2.8 `product_images` Table

```sql
CREATE TABLE product_images (
  id BIGSERIAL PRIMARY KEY,
  product_variant_id BIGINT REFERENCES product_variants(id) ON DELETE CASCADE,
  product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
  -- Note: Image can belong to variant OR product (if shared across variants)
  
  image_url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  medium_url VARCHAR(500),
  large_url VARCHAR(500),
  alt_text VARCHAR(255),
  
  -- Organization
  display_order INTEGER DEFAULT 0,
  is_primary BOOLEAN DEFAULT FALSE,
  image_type VARCHAR(50) DEFAULT 'product', -- product, lifestyle, detail, care_label
  
  -- Metadata
  file_size_bytes INTEGER,
  width_pixels INTEGER,
  height_pixels INTEGER,
  mime_type VARCHAR(50),
  color_dominant VARCHAR(7), -- Hex color code for dominant color
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (product_variant_id IS NOT NULL OR product_id IS NOT NULL),
  
  -- Indexes
  INDEX idx_product_images_variant (product_variant_id),
  INDEX idx_product_images_product (product_id),
  INDEX idx_product_images_display_order (display_order),
  INDEX idx_product_images_primary (is_primary)
);
```

---

## 3. ORDER MANAGEMENT SYSTEM

### 3.1 `orders` Table (Enhanced Order Management)

```sql
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  order_number VARCHAR(50) NOT NULL UNIQUE,
  -- Format: ORD-YYYYMMDD-XXXXXXXX (8 chars)
  
  user_id BIGINT NOT NULL REFERENCES users(id),
  
  -- Addresses
  shipping_address_id BIGINT NOT NULL REFERENCES addresses(id),
  billing_address_id BIGINT NOT NULL REFERENCES addresses(id),
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, confirmed, processing, packed, shipped, 
  --         delivered, cancelled, returned, refunded
  status_updated_at TIMESTAMP,
  status_history JSONB DEFAULT '[]',
  -- Format: [{"status": "pending", "timestamp": "...", "note": "..."}]
  
  -- Payment
  payment_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- Values: pending, paid, failed, refunded, partially_refunded
  payment_method VARCHAR(50), -- cod, credit_card, debit_card, upi, wallet, netbanking
  payment_id VARCHAR(255), -- Payment gateway transaction ID
  payment_gateway VARCHAR(50), -- razorpay, stripe, payu, etc.
  paid_at TIMESTAMP,
  
  -- Pricing Breakdown
  subtotal DECIMAL(10, 2) NOT NULL,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  shipping_charge DECIMAL(10, 2) DEFAULT 0,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  coupon_discount DECIMAL(10, 2) DEFAULT 0,
  loyalty_points_used INTEGER DEFAULT 0,
  loyalty_points_discount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  
  -- Shipping
  shipping_method VARCHAR(50),
  shipping_provider VARCHAR(100), -- delhivery, fedex, etc.
  tracking_number VARCHAR(255),
  tracking_url VARCHAR(500),
  estimated_delivery_date DATE,
  actual_delivery_date DATE,
  delivery_slot_start TIMESTAMP,
  delivery_slot_end TIMESTAMP,
  
  -- Notes
  customer_notes TEXT,
  internal_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cancelled_at TIMESTAMP,
  
  -- Constraints
  CHECK (status IN ('pending', 'confirmed', 'processing', 'packed', 'shipped', 
                    'delivered', 'cancelled', 'returned', 'refunded')),
  CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'partially_refunded')),
  CHECK (total_amount >= 0),
  
  -- Indexes
  INDEX idx_orders_user (user_id),
  INDEX idx_orders_order_number (order_number),
  INDEX idx_orders_status (status),
  INDEX idx_orders_payment_status (payment_status),
  INDEX idx_orders_created_at (created_at),
  INDEX idx_orders_tracking (tracking_number)
);
```

---

### 3.2 `order_items` Table (Per-Supplier Order Items)

```sql
CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  
  -- Product Information (snapshot at time of order)
  product_id BIGINT NOT NULL REFERENCES products(id),
  product_variant_id BIGINT NOT NULL REFERENCES product_variants(id),
  supplier_profile_id BIGINT NOT NULL REFERENCES supplier_profiles(id),
  
  -- Product Details (snapshot)
  product_name VARCHAR(255) NOT NULL,
  product_variant_attributes JSONB, -- Snapshot of variant attributes
  -- Example: {"Color": "Red", "Size": "L"}
  product_image_url VARCHAR(500),
  
  -- Pricing (snapshot at time of order)
  unit_price DECIMAL(10, 2) NOT NULL,
  discounted_price DECIMAL(10, 2),
  final_price DECIMAL(10, 2) NOT NULL, -- Price after discount
  quantity INTEGER NOT NULL DEFAULT 1,
  total_price DECIMAL(10, 2) NOT NULL, -- final_price * quantity
  currency VARCHAR(10) DEFAULT 'INR',
  
  -- Fulfillment (per supplier)
  fulfillment_status VARCHAR(50) DEFAULT 'pending',
  -- Values: pending, processing, packed, shipped, delivered, 
  --         cancelled, returned, refunded
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  tracking_number VARCHAR(255),
  tracking_url VARCHAR(500),
  
  -- Supplier-specific
  supplier_commission DECIMAL(10, 2),
  supplier_paid BOOLEAN DEFAULT FALSE,
  supplier_paid_at TIMESTAMP,
  supplier_payment_id VARCHAR(255),
  
  -- Return/Refund
  is_returnable BOOLEAN DEFAULT TRUE,
  return_deadline DATE,
  return_requested BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CHECK (quantity > 0),
  CHECK (fulfillment_status IN ('pending', 'processing', 'packed', 'shipped', 
                                 'delivered', 'cancelled', 'returned', 'refunded')),
  
  -- Indexes
  INDEX idx_order_items_order (order_id),
  INDEX idx_order_items_supplier (supplier_profile_id),
  INDEX idx_order_items_product (product_id),
  INDEX idx_order_items_variant (product_variant_id),
  INDEX idx_order_items_fulfillment (fulfillment_status)
);
```

---

This is **Chunk 1** covering the core foundation. The remaining chunks will cover:
- **Chunk 2**: Advanced features (Payment, Logistics, Analytics, Notifications)
- **Chunk 3**: Supporting features (Coupons, Reviews, Returns, Inventory tracking)

Would you like me to continue with Chunk 2 next?


