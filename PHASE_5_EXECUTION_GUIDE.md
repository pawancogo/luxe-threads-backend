# Phase 5: Testing & Optimization - Execution Guide

**Date:** 2025-01-18  
**Status:** Ready for Execution ✅

---

## 🚀 Quick Start

### Step 1: Run Performance Index Migration
```bash
cd luxe-threads-backend
rails db:migrate
```

This will add **30+ performance indexes** to optimize query performance.

### Step 2: Run Data Validation
```bash
rails data:validate
```

This checks for:
- Orphaned records
- Data consistency issues
- Invalid data
- Missing references

### Step 3: Run Data Migrations (Optional)
```bash
rails data:migrate
```

This will:
- Migrate products (generate slugs, update prices)
- Migrate orders (generate order numbers, initialize history)
- Calculate metrics (ratings, counts)
- Migrate suppliers (if suppliers table exists)

### Step 4: Run Tests
```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test suites
bundle exec rspec spec/models/notification_spec.rb
bundle exec rspec spec/requests/api/v1/notifications_spec.rb
```

### Step 5: Run Performance Benchmarks
```bash
rails performance:benchmark
rails performance:analyze_queries
```

---

## 📋 Detailed Execution Steps

### 1. Database Migration

**File:** `db/migrate/20250118000001_add_performance_indexes_phase5.rb`

**What it does:**
- Adds composite indexes for common query patterns
- Adds partial indexes for filtered queries
- Adds GIN indexes for JSONB columns (PostgreSQL)
- Adds unique indexes for slugs and identifiers

**Expected time:** 1-5 minutes (depending on data size)

**Rollback:** `rails db:rollback STEP=1`

### 2. Data Validation

**Command:** `rails data:validate`

**What it checks:**
- ✅ Referential integrity (orphaned records)
- ✅ Data consistency (invalid statuses, negative values)
- ✅ Missing required references

**Expected output:**
```
==========================================
Starting Data Validation
==========================================
Checking referential integrity...
Checking data consistency...
✅ All data validation checks passed!
==========================================
```

### 3. Data Migrations

**Command:** `rails data:migrate`

**What it does:**
- Updates product base prices from variants
- Generates missing product slugs
- Updates inventory metrics
- Generates missing order numbers
- Initializes order status history
- Calculates product ratings
- Updates category/brand product counts
- Resets counter caches

**Expected time:** 5-15 minutes (depending on data size)

### 4. Running Tests

#### Run All Tests
```bash
bundle exec rspec
```

#### Run with Coverage
```bash
COVERAGE=true bundle exec rspec
# Open coverage/index.html to view coverage report
```

#### Run Specific Test Suites
```bash
# Phase 4 API tests
bundle exec rspec spec/requests/api/v1/notifications_spec.rb
bundle exec rspec spec/requests/api/v1/support_tickets_spec.rb
bundle exec rspec spec/requests/api/v1/loyalty_points_spec.rb
bundle exec rspec spec/requests/api/v1/product_views_spec.rb

# Phase 4 Model tests
bundle exec rspec spec/models/notification_spec.rb
bundle exec rspec spec/models/support_ticket_spec.rb
bundle exec rspec spec/models/loyalty_points_transaction_spec.rb
bundle exec rspec spec/models/product_view_spec.rb
bundle exec rspec spec/models/support_ticket_message_spec.rb
```

### 5. Performance Testing

#### Run Benchmarks
```bash
rails performance:benchmark
```

**Output:**
- Query execution times
- Average query time
- Performance comparisons

#### Analyze Query Plans
```bash
rails performance:analyze_queries
```

**Output:**
- EXPLAIN plans for critical queries
- Index usage verification
- Query optimization suggestions

---

## 📊 Expected Results

### Performance Improvements

**Before Indexes:**
- Orders query: ~200-500ms
- Products query: ~300-600ms
- Notifications query: ~150-400ms

**After Indexes (Expected):**
- Orders query: ~50-150ms (50-70% faster)
- Products query: ~80-200ms (60-80% faster)
- Notifications query: ~30-100ms (70-90% faster)

### Test Coverage

**Current:**
- 41+ spec files
- 4 new Phase 4 integration test files
- 5 new Phase 4 model test files
- Coverage: TBD (run SimpleCov)

**Target:**
- 80%+ overall coverage
- 90%+ for critical paths (orders, payments, products)

---

## ✅ Verification Checklist

### Before Running
- [ ] Database backup created
- [ ] Staging environment ready
- [ ] All Phase 1-4 migrations run

### After Migration
- [ ] Migration completed successfully
- [ ] All indexes created
- [ ] No errors in logs
- [ ] Application starts normally

### After Data Validation
- [ ] No orphaned records
- [ ] No data consistency issues
- [ ] All validations passed

### After Tests
- [ ] All tests pass
- [ ] Coverage > 80%
- [ ] No performance regressions

---

## 🐛 Troubleshooting

### Migration Fails
```bash
# Check migration status
rails db:migrate:status

# Rollback if needed
rails db:rollback

# Check logs
tail -f log/development.log
```

### Tests Fail
```bash
# Check test database
rails db:test:prepare

# Run specific failing test
bundle exec rspec spec/path/to/failing_test.rb

# Check for missing factories
bundle exec rspec --format documentation
```

### Performance Issues
```bash
# Analyze slow queries
rails performance:analyze_queries

# Check index usage
rails dbconsole
# Then run: EXPLAIN ANALYZE <query>;
```

---

## 📝 Notes

- **Index Creation:** Takes time on large datasets
- **Data Migration:** Can be run multiple times safely
- **Tests:** Require test database to be prepared
- **Performance:** Benchmarks are approximate

---

*Phase 5 Execution Guide - 2025-01-18*

