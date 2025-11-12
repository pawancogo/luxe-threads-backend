# Frontend Architecture - Customer & Supplier Only

## Overview

The frontend React application is designed to handle **customer and supplier functionality only**. Admin functionality is completely handled by the backend HTML interface.

---

## Frontend Scope

### ✅ Customer Functionality
- Product browsing and search
- Shopping cart
- Wishlist
- Orders and order history
- Returns
- Address management
- Profile management
- Support tickets
- Notifications
- Loyalty points
- Authentication (login/signup)

### ✅ Supplier Functionality
- Supplier dashboard
- Product management (CRUD)
- Product variant management
- Order fulfillment
- Return processing
- Analytics
- Supplier profile management
- Document upload (KYC)
- Supplier team management

### ❌ Admin Functionality (Backend Only)
- Admin login/logout → Backend HTML interface at `/admin/login`
- User management → Backend HTML interface at `/admin/users`
- Supplier management → Backend HTML interface at `/admin/suppliers`
- Product moderation → Backend HTML interface at `/admin/products`
- Order management → Backend HTML interface at `/admin/orders`
- Reports & Analytics → Backend HTML interface at `/admin/reports`
- Settings → Backend HTML interface at `/admin/settings`
- Email templates → Backend HTML interface at `/admin/email_templates`
- RBAC management → Backend HTML interface at `/admin/roles-permissions`
- Admin management → Backend HTML interface at `/admin/admins`

---

## API Endpoints Usage

### Frontend Uses These Endpoints

**Customer Endpoints:**
- ✅ `/api/v1/signup` - Customer signup
- ✅ `/api/v1/login` - Customer login
- ✅ `/api/v1/logout` - Customer logout
- ✅ `/api/v1/public/products` - Product listing
- ✅ `/api/v1/cart` - Cart management
- ✅ `/api/v1/cart_items` - Cart items
- ✅ `/api/v1/wishlist/items` - Wishlist
- ✅ `/api/v1/orders` - Customer orders
- ✅ `/api/v1/addresses` - Addresses
- ✅ `/api/v1/return_requests` - Returns
- ✅ `/api/v1/support_tickets` - Support
- ✅ `/api/v1/notifications` - Notifications
- ✅ `/api/v1/loyalty_points` - Loyalty points
- ✅ All other customer-facing endpoints

**Supplier Endpoints:**
- ✅ `/api/v1/products` - Supplier products
- ✅ `/api/v1/supplier/orders` - Supplier orders
- ✅ `/api/v1/supplier/returns` - Supplier returns
- ✅ `/api/v1/supplier/analytics` - Analytics
- ✅ `/api/v1/supplier_profile` - Profile
- ✅ `/api/v1/supplier/documents` - Documents
- ✅ `/api/v1/supplier/shipments` - Shipments
- ✅ `/api/v1/supplier/payments` - Payments
- ✅ `/api/v1/supplier/users` - Team management
- ✅ All other supplier-facing endpoints

### Frontend Does NOT Use These Endpoints

**Admin Endpoints (Backend HTML Interface Only):**
- ❌ `/api/v1/admin/*` - All admin endpoints
- ❌ `/api/v1/admin/login` - Admin login (backend HTML)
- ❌ `/api/v1/admin/users` - User management (backend HTML)
- ❌ `/api/v1/admin/suppliers` - Supplier management (backend HTML)
- ❌ `/api/v1/admin/products` - Product moderation (backend HTML)
- ❌ `/api/v1/admin/orders` - Order management (backend HTML)
- ❌ `/api/v1/admin/reports` - Reports (backend HTML)
- ❌ `/api/v1/admin/settings` - Settings (backend HTML)
- ❌ `/api/v1/admin/rbac/*` - RBAC (backend HTML)

**Note:** These admin API endpoints exist for the backend HTML interface to use, not for the frontend React app.

---

## Frontend Routes

### Customer Routes
- `/` - Home
- `/products` - Product listing
- `/product/:id` - Product details
- `/cart` - Shopping cart
- `/checkout` - Checkout
- `/orders` - Order history
- `/orders/:id` - Order details
- `/wishlist` - Wishlist
- `/profile` - User profile
- `/addresses` - Addresses
- `/returns` - Returns
- `/support-tickets` - Support
- `/notifications` - Notifications
- `/loyalty-points` - Loyalty points
- `/auth` - Login/signup
- `/forgot-password` - Password reset
- `/reset-password` - Password reset
- `/verify-email` - Email verification

### Supplier Routes
- `/supplier` - Supplier dashboard

### Admin Routes
- `/admin/*` - Redirects to backend HTML interface

---

## Context Providers

### Active Contexts (Customer & Supplier)
- ✅ `UserProvider` - Customer/supplier user context
- ✅ `SupplierProvider` - Supplier-specific context
- ✅ `ProductProvider` - Product context
- ✅ `FilterProvider` - Filter context
- ✅ `CartProvider` - Cart context
- ✅ `NotificationProvider` - Notification context

### Removed Contexts (Admin Only)
- ❌ `AdminProvider` - Not needed (backend only)
- ❌ `RbacProvider` - Not needed (backend only)

---

## API Service Methods

### Customer & Supplier API Methods (Used)
- ✅ `authAPI` - Customer authentication
- ✅ `usersAPI` - Customer profile
- ✅ `productsAPI` - Products (public & supplier)
- ✅ `cartAPI` - Cart
- ✅ `wishlistAPI` - Wishlist
- ✅ `ordersAPI` - Customer orders
- ✅ `supplierOrdersAPI` - Supplier orders
- ✅ `addressesAPI` - Addresses
- ✅ `returnRequestsAPI` - Returns
- ✅ `supportTicketsAPI` - Support
- ✅ `notificationsAPI` - Notifications
- ✅ `loyaltyPointsAPI` - Loyalty points
- ✅ `supplierProfileAPI` - Supplier profile
- ✅ `supplierDocumentsAPI` - Documents
- ✅ `supplierAnalyticsAPI` - Analytics
- ✅ `supplierUsersAPI` - Supplier team management
- ✅ All other customer/supplier endpoints

### Admin API Methods (Not Used by Frontend)
- ❌ `adminAuthAPI` - Backend HTML interface only
- ❌ `adminUsersAPI` - Backend HTML interface only
- ❌ `adminAdminsAPI` - Backend HTML interface only
- ❌ `adminSuppliersAPI` - Backend HTML interface only
- ❌ `adminProductsAPI` - Backend HTML interface only
- ❌ `adminOrdersAPI` - Backend HTML interface only
- ❌ `adminReportsAPI` - Backend HTML interface only
- ❌ `adminSettingsAPI` - Backend HTML interface only
- ❌ `adminEmailTemplatesAPI` - Backend HTML interface only
- ❌ `adminSearchAPI` - Backend HTML interface only
- ❌ `rbacAPI` - Backend HTML interface only

**Note:** These API methods are kept in the codebase for reference but are not used by the frontend React app. They are used by the backend HTML interface.

---

## Backend HTML Interface

Admin functionality is accessed via the backend HTML interface:

**Base URL:** `http://localhost:3000/admin` (or production domain)

**Admin Routes:**
- `/admin/login` - Admin login
- `/admin/dashboard` - Admin dashboard
- `/admin/users` - User management
- `/admin/suppliers` - Supplier management
- `/admin/products` - Product moderation
- `/admin/orders` - Order management
- `/admin/reports` - Reports
- `/admin/settings` - Settings
- `/admin/email_templates` - Email templates
- `/admin/roles-permissions` - RBAC management
- `/admin/admins` - Admin management

---

## Integration Summary

### What Frontend Integrates With

1. **Customer API Endpoints** - All customer-facing functionality
2. **Supplier API Endpoints** - All supplier-facing functionality
3. **Public API Endpoints** - Product listing, search, categories, brands

### What Frontend Does NOT Integrate With

1. **Admin API Endpoints** - All admin endpoints are for backend HTML interface
2. **Admin Pages** - No admin pages in frontend React app
3. **Admin Contexts** - No admin contexts needed

---

## Updated Integration Status

**Frontend Integration:**
- Customer Functionality: ✅ 100%
- Supplier Functionality: ✅ 100%
- Admin Functionality: ❌ 0% (Backend HTML only)

**Backend Integration:**
- Customer API: ✅ 100%
- Supplier API: ✅ 100%
- Admin API: ✅ 100% (For backend HTML interface)
- Admin HTML Interface: ✅ 100%

---

## Files to Keep/Remove

### Keep in Frontend
- ✅ All customer pages
- ✅ All supplier pages
- ✅ Customer/supplier API service methods
- ✅ Customer/supplier contexts
- ✅ Customer/supplier hooks

### Can Remove from Frontend (Optional)
- ❌ Admin pages (not used)
- ❌ Admin contexts (not used)
- ❌ Admin hooks (not used)
- ⚠️ Admin API methods (keep for reference, but mark as backend-only)

---

## Recommendation

1. **Keep admin API methods** in `api.ts` but document they're for backend HTML interface
2. **Remove admin pages** from frontend (or keep as redirect pages)
3. **Remove admin contexts** from App.tsx
4. **Update documentation** to clarify frontend scope

