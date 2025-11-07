# Phase 1: Foundation Migration - Execution Guide

This guide walks you through executing Phase 1 migrations step by step.

---

## 📋 Prerequisites

1. **Backup Database**
   ```bash
   # Create a full database backup before starting
   rails db:backup  # or your backup method
   ```

2. **Check Current State**
   ```bash
   # Check current migration status
   rails db:migrate:status
   
   # Check data counts
   rails runner "puts 'Users: ' + User.count.to_s"
   rails runner "puts 'Suppliers: ' + Supplier.count.to_s"
   rails runner "puts 'Supplier Profiles: ' + SupplierProfile.count.to_s"
   ```

---

## 🚀 Step-by-Step Execution

### Step 1: Run Backup Migration

```bash
rails db:migrate:up VERSION=20250115000001
```

**What it does:**
- Creates backup tables: `users_backup`, `suppliers_backup`, `supplier_profiles_backup`
- Preserves current data for rollback safety

**Verify:**
```bash
rails runner "puts 'Backup tables created' if ActiveRecord::Base.connection.table_exists?('users_backup')"
```

---

### Step 2: Enhance Users Table

```bash
rails db:migrate:up VERSION=20250115000002
```

**What it does:**
- Adds profile fields (alternate_phone, date_of_birth, gender, etc.)
- Adds referral & loyalty fields
- Adds preferences (language, currency, timezone)
- Adds account status fields
- Adds social login fields
- Adds indexes and constraints

**Verify:**
```bash
rails runner "u = User.first; puts 'Users enhanced: ' + (u.respond_to?(:referral_code) ? 'YES' : 'NO')"
```

---

### Step 3: Enhance Supplier Profiles (First Part)

```bash
rails db:migrate:up VERSION=20250115000004
```

**What it does:**
- Adds owner_user_id column (required)
- Adds all new columns to supplier_profiles
- Sets up for data migration

**Note:** This creates the structure, but owner_user_id will be set by the data migration.

---

### Step 4: Create Supplier Account Users Table

```bash
rails db:migrate:up VERSION=20250115000005
```

**What it does:**
- Creates supplier_account_users table
- Sets up multi-user account system

**Note:** This table must exist before running the data migration.

---

### Step 5: Run Data Migration (CRITICAL STEP)

**This is the actual data migration from Supplier to User:**

```bash
rails data:migrate_suppliers_to_users
```

**What it does:**
- For each Supplier record:
  - Checks if User exists with same email
  - If yes: Updates User role to 'supplier' and links SupplierProfile
  - If no: Creates new User with supplier role
  - Maps Supplier.role to SupplierProfile.supplier_tier
  - Links SupplierProfile to User

**Verify Migration:**
```bash
rails data:verify_supplier_migration
```

**Expected Output:**
```
✅ Suppliers in suppliers table: 0
✅ Users with supplier role: X
✅ Total supplier_profiles: X
✅ Supplier_profiles with owner_user_id: X
✅ Migration verification passed!
```

**If verification fails:**
- Review the migration output
- Check for errors in the rake task output
- Fix any issues and re-run if needed

---

### Step 6: Remove Supplier ID from Supplier Profiles

```bash
rails db:migrate:up VERSION=20250115000006
```

**What it does:**
- Ensures all supplier_profiles have owner_user_id
- Removes foreign key constraint to suppliers
- Removes supplier_id column from supplier_profiles

**Verify:**
```bash
rails runner "sp = SupplierProfile.first; puts 'supplier_id removed: ' + (sp.respond_to?(:supplier_id) ? 'NO (still exists)' : 'YES')"
```

---

### Step 7: Drop Suppliers Table

```bash
rails db:migrate:up VERSION=20250115000007
```

**⚠️ WARNING: This permanently removes the suppliers table!**

**What it does:**
- Verifies all suppliers have been migrated
- Drops the suppliers table

**Verify:**
```bash
rails runner "puts 'Suppliers table exists: ' + (ActiveRecord::Base.connection.table_exists?('suppliers') ? 'YES' : 'NO')"
```

---

### Step 8: Enhance Addresses Table

```bash
rails db:migrate:up VERSION=20250115000008
```

**What it does:**
- Adds address details (label, alternate_phone, landmark)
- Adds location data (latitude, longitude, pincode_id)
- Adds verification fields
- Adds delivery instructions
- Adds indexes

**Verify:**
```bash
rails runner "a = Address.first; puts 'Addresses enhanced: ' + (a.respond_to?(:label) ? 'YES' : 'NO')"
```

---

## ✅ Final Verification

Run comprehensive verification:

```bash
# Check all migrations ran
rails db:migrate:status | grep "2025011500000"

# Verify data integrity
rails data:verify_supplier_migration

# Check user counts
rails runner "
  puts 'Total Users: ' + User.count.to_s
  puts 'Supplier Users: ' + User.where(role: 'supplier').count.to_s
  puts 'Customer Users: ' + User.where(role: 'customer').count.to_s
"

# Check supplier profiles
rails runner "
  puts 'Total Supplier Profiles: ' + SupplierProfile.count.to_s
  puts 'Supplier Profiles with Owner: ' + SupplierProfile.where.not(owner_user_id: nil).count.to_s
  puts 'Supplier Account Users: ' + SupplierAccountUser.count.to_s
"
```

---

## 🔄 Rollback Instructions

If you need to rollback:

### Full Rollback (All Phase 1 migrations)

```bash
# Rollback in reverse order
rails db:migrate:down VERSION=20250115000008  # Addresses
rails db:migrate:down VERSION=20250115000007  # Drop Suppliers
rails db:migrate:down VERSION=20250115000006  # Remove supplier_id
rails db:migrate:down VERSION=20250115000005  # Supplier Account Users
rails db:migrate:down VERSION=20250115000004  # Enhance Supplier Profiles
rails db:migrate:down VERSION=20250115000003  # Migrate Suppliers
rails db:migrate:down VERSION=20250115000002  # Enhance Users
rails db:migrate:down VERSION=20250115000001  # Backup
```

### Restore from Backup

If you need to restore data:

```bash
# Restore from backup tables (if needed)
rails runner "
  execute('INSERT INTO users SELECT * FROM users_backup WHERE NOT EXISTS (SELECT 1 FROM users WHERE users.id = users_backup.id)')
  execute('INSERT INTO suppliers SELECT * FROM suppliers_backup WHERE NOT EXISTS (SELECT 1 FROM suppliers WHERE suppliers.id = suppliers_backup.id)')
  execute('INSERT INTO supplier_profiles SELECT * FROM supplier_profiles_backup WHERE NOT EXISTS (SELECT 1 FROM supplier_profiles WHERE supplier_profiles.id = supplier_profiles_backup.id)')
"
```

---

## 🐛 Troubleshooting

### Issue: Migration fails on supplier migration

**Solution:**
```bash
# Check for duplicate emails
rails runner "Supplier.all.group(:email).having('COUNT(*) > 1').count.each { |email, count| puts \"#{email}: #{count}\" }"

# Check for missing supplier_profiles
rails runner "Supplier.all.each { |s| puts \"Supplier #{s.id} has no profile\" unless SupplierProfile.find_by(supplier_id: s.id) }"
```

### Issue: owner_user_id is NULL

**Solution:**
```bash
# Manually set owner_user_id
rails runner "
  SupplierProfile.where(owner_user_id: nil).each do |sp|
    if sp.user_id
      sp.update(owner_user_id: sp.user_id)
    elsif sp.supplier_id
      supplier = Supplier.find(sp.supplier_id)
      user = User.find_by(email: supplier.email)
      sp.update(owner_user_id: user.id) if user
    end
  end
"
```

### Issue: Check constraint violations

**Solution:**
```bash
# Check for invalid data
rails runner "
  User.where.not(role: ['customer', 'premium_customer', 'vip_customer', 'supplier', 'super_admin', 'product_admin', 'order_admin', 'support_admin']).each { |u| puts \"Invalid role: #{u.role} for user #{u.id}\" }
"
```

---

## 📊 Success Criteria

Phase 1 is complete when:

- [ ] All migrations run successfully
- [ ] No suppliers table exists
- [ ] All suppliers converted to users
- [ ] All supplier_profiles have owner_user_id
- [ ] All supplier_account_users have owner records
- [ ] Users table enhanced with all new fields
- [ ] Addresses table enhanced
- [ ] Verification script passes
- [ ] No data loss

---

## 🚀 Next Steps

After Phase 1 is complete:

1. Update models to reflect new schema
2. Update controllers to use new associations
3. Update policies for multi-user accounts
4. Test all functionality
5. Proceed to Phase 2

---

**Important Notes:**
- ⚠️ Always backup before running migrations
- ⚠️ Run migrations in order
- ⚠️ Verify after each step
- ⚠️ Test in staging first
- ⚠️ Monitor for errors

