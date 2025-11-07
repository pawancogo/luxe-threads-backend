# Comprehensive Refactoring & Optimization Plan
## Phase 1-3 Code Cleanup & Optimization

## 🎯 Goals
1. Remove unnecessary code
2. Optimize for performance and scalability
3. Improve maintainability
4. Break down large components
5. Use Rails built-in features
6. Follow best practices

---

## 📋 Backend Refactoring Tasks

### 1. API Response Formatting
**Issue:** Duplicate formatting logic across controllers
**Solution:** Create shared formatters/concerns
- `app/controllers/concerns/api_formatters.rb` - Product, Order, Cart formatters
- Use Rails `as_json` with serializers where appropriate

### 2. Controllers Optimization
**Files to refactor:**
- `public_products_controller.rb` - Extract formatting to concern
- `cart_items_controller.rb` - Simplify format methods
- `wishlist_items_controller.rb` - Use shared formatter
- `orders_controller.rb` - Extract formatting logic
- `supplier_orders_controller.rb` - Use shared formatter

### 3. Services Optimization
**Files to refactor:**
- `product_filter_service.rb` - Use ActiveRecord scopes more
- `user_creation_service.rb` - Simplify error handling
- Remove duplicate logic

### 4. Models
- Add missing scopes
- Use ActiveRecord callbacks properly
- Optimize associations with `includes`/`joins`

### 5. Remove Dead Code
- Unused services
- Deprecated methods
- Commented code blocks

---

## 📋 Frontend Refactoring Tasks

### 1. Component Breakdown
**Large Components to Split:**
- `SupplierDashboardContainer.tsx` (460 lines) → Split into smaller hooks/components
- `Products.tsx` (302 lines) → Extract filters, grid, pagination
- `Auth.tsx` (315 lines) → Split into Login/Register components
- `ProductDetail.tsx` → Extract image gallery, variant selector, reviews

### 2. Context Optimization
- Remove duplicate state management
- Consolidate similar contexts if needed
- Optimize re-renders

### 3. API Service
- Remove duplicate API calls
- Consolidate similar endpoints
- Optimize error handling

### 4. Remove Unused Code
- Dead components
- Unused hooks
- Commented code

---

## 🔧 Implementation Priority

### Priority 1 (Critical)
1. Fix TypeScript errors
2. Create shared API formatters (backend)
3. Break down largest components

### Priority 2 (High)
4. Optimize database queries
5. Consolidate duplicate logic
6. Remove dead code

### Priority 3 (Medium)
7. Improve error handling consistency
8. Add missing validations
9. Optimize bundle size

---

## 📝 Execution Plan

**Step 1:** Create shared formatters
**Step 2:** Refactor controllers to use formatters
**Step 3:** Break down large frontend components
**Step 4:** Optimize queries and remove N+1
**Step 5:** Clean up unused code
**Step 6:** Final optimization pass


