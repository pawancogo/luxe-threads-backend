# Production Schema Implementation Plan
## Enterprise-Grade Step-by-Step Approach

This document outlines the complete implementation strategy following best practices used by large-scale companies.

---

## 📋 Implementation Strategy Overview

### Phases
1. **Phase 1**: Foundation Migration (Week 1-2)
2. **Phase 2**: Core Features (Week 3-4)
3. **Phase 3**: Advanced Features (Week 5-6)
4. **Phase 4**: Supporting Features (Week 7-8)
5. **Phase 5**: Testing & Optimization (Week 9-10)
6. **Phase 6**: Production Deployment (Week 11-12)

### Approach
- ✅ Incremental migrations (one feature at a time)
- ✅ Feature flags for gradual rollout
- ✅ Comprehensive testing at each phase
- ✅ Rollback plans for each migration
- ✅ Data migration scripts
- ✅ Zero-downtime deployment strategy

---

## 🎯 Phase 1: Foundation Migration (Week 1-2)

### Goal
Migrate from current dual-model (User + Supplier) to unified User model and enhance core tables.

### Step 1.1: Backup & Preparation

**Tasks:**
1. Create database backup
2. Document current data counts
3. Set up feature flags
4. Create staging environment

**Migration Files:**
```ruby
# db/migrate/YYYYMMDDHHMMSS_001_backup_current_schema.rb
# Creates backup tables for rollback
```

---

### Step 1.2: Enhance Users Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_002_enhance_users_table.rb`

**Changes:**
- Add: `alternate_phone`, `date_of_birth`, `gender`, `profile_image_url`
- Add: `referral_code`, `referred_by_id`, `loyalty_points`
- Add: `preferred_language`, `preferred_currency`, `timezone`
- Add: `notification_preferences` (JSONB)
- Add: `is_active`, `is_blocked`, `blocked_reason`, `blocked_at`
- Add: `last_login_at`, `last_active_at`
- Add: `google_id`, `facebook_id`, `apple_id` (social login)
- Add: `password_changed_at`

**Rollback:** Drop columns (data preserved in backup)

---

### Step 1.3: Migrate Suppliers to Users

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_003_migrate_suppliers_to_users.rb`

**Strategy:**
1. Find all Supplier records
2. For each Supplier:
   - Check if User exists with same email
   - If yes: Update User role to 'supplier', link SupplierProfile
   - If no: Create new User with supplier role
3. Migrate SupplierProfile to link to User
4. Map Supplier.role to SupplierProfile.supplier_tier

**Data Migration Script:**
```ruby
# lib/tasks/migrate_suppliers.rake
# Handles the actual data migration
```

---

### Step 1.4: Enhance Supplier Profiles

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_004_enhance_supplier_profiles.rb`

**Changes:**
- Add: `owner_user_id` (required)
- Add: `company_registration_number`, `pan_number`, `cin_number`
- Add: `business_type`, `business_category`
- Add: `warehouse_addresses` (JSONB)
- Add: `contact_email`, `contact_phone`, `support_email`, `support_phone`
- Add: `verification_documents` (JSONB)
- Add: `supplier_tier`, `tier_upgraded_at`
- Add: `max_users`, `allow_invites`, `invite_code`
- Add: `active_products_count`, `total_reviews_count`
- Add: `bank_branch`, `account_holder_name`, `upi_id`
- Add: `payment_cycle`, `handling_time_days`, `shipping_zones`, `free_shipping_above`
- Add: `is_active`, `is_suspended`, `suspended_reason`, `suspended_at`

**Data Migration:**
- Set `owner_user_id` = `user_id` for existing records
- Set default `supplier_tier` = 'basic'
- Initialize metrics to 0

---

### Step 1.5: Create Supplier Account Users Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_005_create_supplier_account_users.rb`

**Creates:**
- `supplier_account_users` table
- All indexes and constraints

**Data Migration:**
- Create owner records for existing suppliers
- Set all permissions to true for owners

---

### Step 1.6: Remove Supplier Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_006_remove_supplier_id_from_supplier_profiles.rb`

**Changes:**
- Remove `supplier_id` column from `supplier_profiles`
- Remove foreign key constraint
- Update `supplier_profiles` to remove `supplier_id` references

**Final Migration:** `db/migrate/YYYYMMDDHHMMSS_007_drop_suppliers_table.rb`
- Drop `suppliers` table (after verification)

---

### Step 1.7: Enhance Addresses Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_008_enhance_addresses_table.rb`

**Changes:**
- Add: `label`, `alternate_phone`, `landmark`
- Add: `latitude`, `longitude`, `pincode_id`
- Add: `is_verified`, `verification_status`
- Add: `delivery_instructions`

---

### Testing Checklist - Phase 1
- [ ] All existing users can log in
- [ ] All suppliers converted to users
- [ ] Supplier profiles accessible
- [ ] Multi-user supplier accounts work
- [ ] Addresses enhanced correctly
- [ ] No data loss
- [ ] All indexes working

---

## 🎯 Phase 2: Core Features (Week 3-4)

### Step 2.1: Enhance Categories Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_009_enhance_categories_table.rb`

**Changes:**
- Add: `slug`, `level`, `path`, `sort_order`
- Add: `short_description`, `image_url`, `banner_url`, `icon_url`
- Add: `meta_title`, `meta_description`, `meta_keywords`
- Add: `featured`, `products_count`, `active_products_count`
- Add: `require_brand`, `require_attributes` (JSONB)

**Data Migration:**
- Generate slugs for existing categories
- Calculate and set `level` and `path`
- Initialize counts

---

### Step 2.2: Enhance Brands Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_010_enhance_brands_table.rb`

**Changes:**
- Add: `slug`, `short_description`, `banner_url`
- Add: `country_of_origin`, `founded_year`, `website_url`
- Add: `active`, `products_count`, `active_products_count`
- Add: `meta_title`, `meta_description`

---

### Step 2.3: Enhance Products Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_011_enhance_products_table.rb`

**Changes:**
- Add: `slug`, `short_description`, `highlights` (array)
- Add: `product_type`, `status_changed_at`, `status_changed_by_id`
- Add: `meta_title`, `meta_description`, `meta_keywords`
- Add: `search_keywords` (array), `tags` (array)
- Add: `product_attributes` (JSONB)
- Add: `base_price`, `base_discounted_price`, `base_mrp`
- Add: `length_cm`, `width_cm`, `height_cm`, `weight_kg`
- Add: `rating_distribution` (JSONB)
- Add: `total_clicks_count`, `conversion_rate`
- Add: `total_stock_quantity`, `low_stock_variants_count`
- Add: `is_featured`, `is_bestseller`, `is_new_arrival`, `is_trending`
- Add: `published_at`

**Data Migration:**
- Generate slugs for existing products
- Set default `product_type` based on category
- Initialize metrics to 0
- Set `status` enum values

---

### Step 2.4: Enhance Product Variants Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_012_enhance_product_variants_table.rb`

**Changes:**
- Add: `barcode`, `ean_code`, `isbn`
- Add: `cost_price`, `mrp`, `currency`
- Add: `reserved_quantity`
- Add: `available_quantity` (generated column)
- Add: `low_stock_threshold`, `is_low_stock` (generated column)
- Add: `out_of_stock` (generated column)
- Add: `variant_attributes` (JSONB)
- Add: `primary_image_id`
- Add: `total_returned`, `total_refunded`
- Add: `is_available` (generated column)

---

### Step 2.5: Enhance Attribute Types Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_013_enhance_attribute_types_table.rb`

**Changes:**
- Add: `display_name`, `data_type`
- Add: `is_variant_attribute`, `applicable_product_types` (array)
- Add: `applicable_categories` (array)
- Add: `display_type`, `validation_rules` (JSONB)

---

### Step 2.6: Enhance Attribute Values Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_014_enhance_attribute_values_table.rb`

**Changes:**
- Add: `display_value`, `display_order`
- Add: `metadata` (JSONB)

---

### Step 2.7: Enhance Product Images Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_015_enhance_product_images_table.rb`

**Changes:**
- Add: `product_id` (make optional)
- Add: `thumbnail_url`, `medium_url`, `large_url`
- Add: `image_type`, `color_dominant`
- Add: `file_size_bytes`, `width_pixels`, `height_pixels`, `mime_type`

---

### Step 2.8: Enhance Orders Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_016_enhance_orders_table.rb`

**Changes:**
- Add: `order_number` (unique)
- Add: `status_updated_at`, `status_history` (JSONB)
- Add: `payment_method`, `payment_id`, `payment_gateway`, `paid_at`
- Add: `tax_amount`, `coupon_discount`, `loyalty_points_used`, `loyalty_points_discount`
- Add: `currency`
- Add: `shipping_provider`, `tracking_url`
- Add: `estimated_delivery_date`, `actual_delivery_date`
- Add: `delivery_slot_start`, `delivery_slot_end`
- Add: `customer_notes`, `internal_notes`

**Data Migration:**
- Generate `order_number` for existing orders
- Update status enum values

---

### Step 2.9: Enhance Order Items Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_017_enhance_order_items_table.rb`

**Changes:**
- Add: `supplier_profile_id` (required)
- Add: `product_name`, `product_variant_attributes` (JSONB), `product_image_url`
- Add: `discounted_price`, `final_price`, `currency`
- Add: `fulfillment_status`, `shipped_at`, `delivered_at`
- Add: `tracking_number`, `tracking_url`
- Add: `supplier_commission`, `supplier_paid`, `supplier_paid_at`, `supplier_payment_id`
- Add: `is_returnable`, `return_deadline`, `return_requested`

**Data Migration:**
- Set `supplier_profile_id` from product's supplier
- Set `fulfillment_status` based on order status
- Snapshot product details

---

### Testing Checklist - Phase 2
- [ ] Categories hierarchy working
- [ ] Products can be created with all attributes
- [ ] Variants have proper inventory tracking
- [ ] Orders track suppliers correctly
- [ ] Order items have proper snapshots
- [ ] All generated columns working

---

## 🎯 Phase 3: Advanced Features (Week 5-6)

### Step 3.1: Create Payment Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_018_create_payments_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_019_create_payment_refunds_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_020_create_supplier_payments_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_021_create_payment_transactions_table.rb`

---

### Step 3.2: Create Shipping Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_022_create_shipping_methods_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_023_create_shipments_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_024_create_shipment_tracking_events_table.rb`

---

### Step 3.3: Create Coupon Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_025_create_coupons_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_026_create_coupon_usages_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_027_create_promotions_table.rb`

---

### Step 3.4: Enhance Reviews Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_028_enhance_reviews_table.rb`

**Changes:**
- Add: `title`, `is_featured`
- Add: `review_images` (JSONB)
- Add: `moderation_status`, `moderated_by_id`, `moderated_at`, `moderation_notes`
- Add: `supplier_response`, `supplier_response_at`
- Add: `helpful_count`, `not_helpful_count`

---

### Step 3.5: Create Review Helpful Votes Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_029_create_review_helpful_votes_table.rb`

---

### Step 3.6: Enhance Return Requests Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_030_enhance_return_requests_table.rb`

**Changes:**
- Add: `return_id` (unique)
- Add: `order_item_id` (required)
- Add: `status_updated_at`, `status_history` (JSONB)
- Add: `resolution_amount`, `resolved_by_admin_id`, `resolved_at`
- Add: `refund_id`, `refund_status`, `refund_amount`, `refund_transaction_id`
- Add: `pickup_address_id`, `pickup_scheduled_at`, `pickup_completed_at`
- Add: `return_quantity`, `return_condition`, `return_images` (JSONB)

---

### Testing Checklist - Phase 3
- [ ] Payments can be processed
- [ ] Shipping tracking works
- [ ] Coupons can be applied
- [ ] Reviews have moderation
- [ ] Returns have full workflow

---

## 🎯 Phase 4: Supporting Features (Week 7-8)

### Step 4.1: Create Inventory Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_031_create_inventory_transactions_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_032_create_warehouses_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_033_create_warehouse_inventory_table.rb`

---

### Step 4.2: Create Analytics Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_034_create_product_views_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_035_create_user_searches_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_036_create_supplier_analytics_table.rb`

---

### Step 4.3: Create Notification Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_037_create_notifications_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_038_create_notification_preferences_table.rb`

---

### Step 4.4: Enhance Wishlist Tables

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_039_enhance_wishlists_table.rb`

**Changes:**
- Add: `name`, `description`, `is_public`, `is_default`
- Add: `share_token`, `share_enabled`

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_040_enhance_wishlist_items_table.rb`

**Changes:**
- Add: `notes`, `priority`
- Add: `price_when_added`, `current_price`, `price_drop_notified`

---

### Step 4.5: Enhance Cart Items Table

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_041_enhance_cart_items_table.rb`

**Changes:**
- Add: `price_when_added`

---

### Step 4.6: Create Search Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_042_create_search_suggestions_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_043_create_trending_products_table.rb`

---

### Step 4.7: Enhance Admin Tables

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_044_enhance_admins_table.rb`

**Changes:**
- Add: `is_active`, `is_blocked`, `last_login_at`
- Add: `password_changed_at`, `permissions` (JSONB)

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_045_create_admin_activities_table.rb`

---

### Step 4.8: Create Support Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_046_create_support_tickets_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_047_create_support_ticket_messages_table.rb`

---

### Step 4.9: Create Loyalty Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_048_create_loyalty_points_transactions_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_049_create_referrals_table.rb`

---

### Step 4.10: Create Additional Tables

**Migration Files:**
- `db/migrate/YYYYMMDDHHMMSS_050_enhance_email_verifications_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_051_create_pincode_serviceability_table.rb`
- `db/migrate/YYYYMMDDHHMMSS_052_create_audit_logs_table.rb`

---

### Testing Checklist - Phase 4
- [ ] Inventory tracking works
- [ ] Analytics collecting data
- [ ] Notifications sending
- [ ] Wishlists enhanced
- [ ] Search working
- [ ] Support tickets functional
- [ ] Loyalty points tracking

---

## 🎯 Phase 5: Testing & Optimization (Week 9-10)

### Step 5.1: Data Migration Scripts

**Create Rake Tasks:**
- `lib/tasks/migrate_data.rake` - Master migration script
- `lib/tasks/migrate_suppliers.rake` - Supplier migration
- `lib/tasks/migrate_products.rake` - Product enhancement
- `lib/tasks/migrate_orders.rake` - Order enhancement
- `lib/tasks/calculate_metrics.rake` - Calculate cached metrics

---

### Step 5.2: Index Optimization

**Migration File:** `db/migrate/YYYYMMDDHHMMSS_053_add_performance_indexes.rb`

**Add Missing Indexes:**
- Composite indexes for common queries
- Partial indexes for filtered queries
- GIN indexes for JSONB columns

---

### Step 5.3: Data Validation

**Create Validation Scripts:**
- `lib/tasks/validate_data.rake`
- Check referential integrity
- Validate data consistency
- Check for orphaned records

---

### Step 5.4: Performance Testing

**Tasks:**
- Load testing with sample data
- Query optimization
- Index usage analysis
- Connection pooling setup

---

## 🎯 Phase 6: Production Deployment (Week 11-12)

### Step 6.1: Feature Flags

**Create Feature Flags:**
- `multi_user_supplier_accounts` - Enable/disable multi-user
- `new_payment_system` - Enable new payment tables
- `enhanced_analytics` - Enable analytics tracking
- `new_notification_system` - Enable new notifications

---

### Step 6.2: Staging Deployment

**Tasks:**
1. Deploy to staging
2. Run full migration
3. Test all features
4. Performance testing
5. Fix issues

---

### Step 6.3: Production Deployment Plan

**Strategy: Zero-Downtime Migration**

1. **Pre-Deployment:**
   - Backup production database
   - Deploy code (not active)
   - Create feature flags (disabled)

2. **Migration Window:**
   - Run migrations in batches
   - Monitor performance
   - Verify data integrity

3. **Post-Deployment:**
   - Enable feature flags gradually
   - Monitor errors
   - Rollback plan ready

---

### Step 6.4: Rollback Plan

**For Each Phase:**
1. Feature flag rollback
2. Code rollback (if needed)
3. Data rollback script
4. Database restore (if critical)

---

## 📝 Migration File Naming Convention

```
YYYYMMDDHHMMSS_XXX_description.rb
```

Where:
- `YYYYMMDDHHMMSS` - Timestamp
- `XXX` - Sequential number (001, 002, etc.)
- `description` - Brief description

**Example:**
```
20250115000001_001_backup_current_schema.rb
20250115000002_002_enhance_users_table.rb
```

---

## 🧪 Testing Strategy

### Unit Tests
- Model validations
- Associations
- Scopes
- Methods

### Integration Tests
- Controller actions
- Service objects
- Background jobs

### Data Migration Tests
- Test migration scripts
- Verify data integrity
- Test rollback scripts

### Performance Tests
- Query performance
- Index usage
- Load testing

---

## 📊 Monitoring & Metrics

### Key Metrics to Monitor
1. Migration execution time
2. Database size growth
3. Query performance
4. Error rates
5. User impact

### Alerts
- Migration failures
- Performance degradation
- Data integrity issues
- High error rates

---

## ✅ Success Criteria

### Phase Completion Criteria
- [ ] All migrations run successfully
- [ ] All tests pass
- [ ] No data loss
- [ ] Performance acceptable
- [ ] Documentation updated
- [ ] Team trained

### Production Ready Criteria
- [ ] All features working
- [ ] Performance optimized
- [ ] Monitoring in place
- [ ] Rollback plan tested
- [ ] Documentation complete
- [ ] Support team trained

---

## 🚀 Next Steps

1. Review this plan with team
2. Set up staging environment
3. Create first migration files
4. Start Phase 1 implementation
5. Daily progress reviews
6. Weekly stakeholder updates

---

**This plan follows enterprise best practices and ensures a smooth, safe migration to the production schema.**


