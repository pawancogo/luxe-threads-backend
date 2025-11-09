# File Storage Structure - Frontend & Backend

## 📋 Overview

This document defines the complete file storage structure for both **Frontend (FE)** and **Backend (BE)** of the Luxe Threads E-commerce Platform. All current and future generated files should follow this structure.

**Last Updated:** 2025-01-18  
**Version:** 1.0

---

## 🗂️ Root Directory Structure

```
ecommerce/
├── luxe-threads-backend/     # Backend (Rails API)
├── luxethreads/              # Frontend (React/TypeScript)
├── manual-testing/           # Manual testing guides (THIS DIRECTORY)
├── docs/                     # Project documentation
└── vendor-backend/           # Vendor backend (separate project)
```

---

## 📁 Backend (Rails) Storage Structure

### Location: `/luxe-threads-backend/`

```
luxe-threads-backend/
├── app/
│   ├── controllers/
│   │   ├── admin/                    # Admin HTML controllers
│   │   │   ├── admins_controller.rb
│   │   │   ├── users_controller.rb
│   │   │   ├── suppliers_controller.rb
│   │   │   ├── products_controller.rb
│   │   │   ├── orders_controller.rb
│   │   │   └── ...
│   │   │
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── admin/            # Admin API controllers
│   │   │       │   ├── admins_controller.rb
│   │   │       │   ├── authentication_controller.rb
│   │   │       │   └── ...
│   │   │       │
│   │   │       ├── authentication_controller.rb
│   │   │       ├── users_controller.rb
│   │   │       ├── products_controller.rb
│   │   │       ├── orders_controller.rb
│   │   │       └── ...
│   │   │
│   │   └── admin_controller.rb       # Admin login/logout
│   │
│   ├── models/
│   │   ├── admin.rb
│   │   ├── user.rb
│   │   ├── supplier_profile.rb
│   │   ├── product.rb
│   │   ├── order.rb
│   │   └── ...
│   │
│   ├── services/
│   │   ├── password_hashing_service.rb
│   │   ├── email_verification_service.rb
│   │   ├── product_filter_service.rb
│   │   └── ...
│   │
│   ├── views/
│   │   ├── layouts/
│   │   │   └── admin.html.erb        # Admin layout
│   │   │
│   │   ├── admin/
│   │   │   ├── login.html.erb
│   │   │   ├── dashboard/
│   │   │   │   └── index.html.erb
│   │   │   ├── admins/
│   │   │   │   ├── index.html.erb
│   │   │   │   ├── show.html.erb
│   │   │   │   ├── new.html.erb
│   │   │   │   ├── edit.html.erb
│   │   │   │   └── _form.html.erb
│   │   │   ├── users/
│   │   │   │   └── ...
│   │   │   ├── suppliers/
│   │   │   │   └── ...
│   │   │   ├── products/
│   │   │   │   └── ...
│   │   │   └── orders/
│   │   │       └── ...
│   │   │
│   │   └── email_verification/
│   │       └── ...
│   │
│   ├── mailers/
│   │   ├── verification_mailer.rb
│   │   └── ...
│   │
│   ├── jobs/
│   │   └── ...
│   │
│   └── concerns/
│       ├── passwordable.rb
│       ├── verifiable.rb
│       ├── auditable.rb
│       └── ...
│
├── config/
│   ├── routes.rb                      # All routes
│   ├── application.rb
│   ├── database.yml
│   ├── environments/
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   └── initializers/
│       └── ...
│
├── db/
│   ├── migrate/                       # Database migrations
│   │   ├── YYYYMMDDHHMMSS_create_admins.rb
│   │   ├── YYYYMMDDHHMMSS_create_users.rb
│   │   └── ...
│   ├── schema.rb
│   └── seeds.rb                       # Seed data
│
├── spec/                              # RSpec tests
│   ├── models/
│   │   ├── admin_spec.rb
│   │   ├── user_spec.rb
│   │   └── ...
│   ├── controllers/
│   │   ├── admin/
│   │   │   └── admins_controller_spec.rb
│   │   └── api/
│   │       └── v1/
│   │           └── ...
│   ├── services/
│   │   └── ...
│   ├── factories/
│   │   ├── admin_factory.rb
│   │   └── ...
│   └── helpers/
│       └── ...
│
├── lib/
│   └── tasks/                         # Rake tasks
│       └── ...
│
├── log/                               # Application logs
├── tmp/                               # Temporary files
└── README.md
```

### Backend File Categories

#### Controllers
- **Admin HTML Controllers:** `app/controllers/admin/*`
- **Admin API Controllers:** `app/controllers/api/v1/admin/*`
- **Public API Controllers:** `app/controllers/api/v1/*`

#### Models
- **Location:** `app/models/`
- **Naming:** `snake_case.rb` (e.g., `admin.rb`, `user.rb`)

#### Services
- **Location:** `app/services/`
- **Naming:** `*_service.rb` (e.g., `password_hashing_service.rb`)

#### Views
- **Admin Views:** `app/views/admin/*`
- **Email Views:** `app/views/*_mailer/*`

#### Tests
- **Model Tests:** `spec/models/*_spec.rb`
- **Controller Tests:** `spec/controllers/**/*_spec.rb`
- **Service Tests:** `spec/services/*_spec.rb`
- **Factories:** `spec/factories/*_factory.rb`

---

## 📁 Frontend (React/TypeScript) Storage Structure

### Location: `/luxethreads/`

```
luxethreads/
├── src/
│   ├── components/
│   │   ├── ui/                        # Reusable UI components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── input.tsx
│   │   │   └── ...
│   │   │
│   │   ├── admin/                     # Admin components
│   │   │   ├── AdminLogin.tsx
│   │   │   ├── orders/
│   │   │   │   └── OrderCard.tsx
│   │   │   ├── products/
│   │   │   │   └── ProductCard.tsx
│   │   │   ├── users/
│   │   │   │   └── UserCard.tsx
│   │   │   ├── reports/
│   │   │   │   └── ReportsCards.tsx
│   │   │   └── ...
│   │   │
│   │   ├── supplier/                  # Supplier components
│   │   │   ├── dashboard/
│   │   │   │   └── SupplierDashboardContainer.tsx
│   │   │   └── ...
│   │   │
│   │   ├── customer/                  # Customer components
│   │   │   ├── ProductCard.tsx
│   │   │   ├── CartItem.tsx
│   │   │   └── ...
│   │   │
│   │   └── common/                    # Shared components
│   │       ├── Navbar.tsx
│   │       ├── Footer.tsx
│   │       ├── LoadingState.tsx
│   │       └── ...
│   │
│   ├── pages/
│   │   ├── admin/                     # Admin pages
│   │   │   ├── AdminLogin.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Users.tsx
│   │   │   ├── Suppliers.tsx
│   │   │   ├── Products.tsx
│   │   │   ├── Orders.tsx
│   │   │   ├── Reports.tsx
│   │   │   ├── Settings.tsx
│   │   │   ├── EmailTemplates.tsx
│   │   │   ├── Coupons.tsx
│   │   │   └── Promotions.tsx
│   │   │
│   │   ├── supplier/                  # Supplier pages
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Products.tsx
│   │   │   ├── Orders.tsx
│   │   │   └── ...
│   │   │
│   │   ├── customer/                  # Customer pages
│   │   │   ├── Home.tsx
│   │   │   ├── Products.tsx
│   │   │   ├── ProductDetail.tsx
│   │   │   ├── Cart.tsx
│   │   │   ├── Checkout.tsx
│   │   │   ├── Orders.tsx
│   │   │   └── ...
│   │   │
│   │   └── auth/                      # Auth pages
│   │       ├── Login.tsx
│   │       ├── Signup.tsx
│   │       └── ...
│   │
│   ├── contexts/
│   │   ├── UserContext.tsx
│   │   ├── AdminContext.tsx
│   │   ├── SupplierContext.tsx
│   │   ├── CartContext.tsx
│   │   └── ...
│   │
│   ├── hooks/
│   │   ├── admin/                     # Admin hooks
│   │   │   ├── useAdminUsers.ts
│   │   │   ├── useAdminProducts.ts
│   │   │   ├── useAdminOrders.ts
│   │   │   ├── useAdminSuppliers.ts
│   │   │   ├── useAdminReports.ts
│   │   │   ├── useAdminCoupons.ts
│   │   │   └── useAdminPromotions.ts
│   │   │
│   │   ├── supplier/                  # Supplier hooks
│   │   │   ├── useSupplierProducts.ts
│   │   │   ├── useSupplierOrders.ts
│   │   │   └── ...
│   │   │
│   │   ├── useAuth.ts
│   │   ├── useCart.ts
│   │   └── ...
│   │
│   ├── services/
│   │   ├── api.ts                      # Main API service
│   │   ├── auth.service.ts
│   │   ├── products.service.ts
│   │   ├── orders.service.ts
│   │   └── ...
│   │
│   ├── types/
│   │   ├── admin.ts
│   │   ├── user.ts
│   │   ├── product.ts
│   │   ├── order.ts
│   │   └── ...
│   │
│   ├── utils/
│   │   ├── format.ts
│   │   ├── validation.ts
│   │   └── ...
│   │
│   ├── App.tsx
│   ├── main.tsx
│   └── router.tsx                     # Route definitions
│
├── public/
│   ├── index.html
│   └── ...
│
├── tests/                              # Frontend tests (if any)
│   └── ...
│
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

### Frontend File Categories

#### Components
- **UI Components:** `src/components/ui/*`
- **Admin Components:** `src/components/admin/*`
- **Supplier Components:** `src/components/supplier/*`
- **Customer Components:** `src/components/customer/*`
- **Common Components:** `src/components/common/*`

#### Pages
- **Admin Pages:** `src/pages/admin/*`
- **Supplier Pages:** `src/pages/supplier/*`
- **Customer Pages:** `src/pages/customer/*`
- **Auth Pages:** `src/pages/auth/*`

#### Contexts
- **Location:** `src/contexts/*`
- **Naming:** `*Context.tsx`

#### Hooks
- **Admin Hooks:** `src/hooks/admin/*`
- **Supplier Hooks:** `src/hooks/supplier/*`
- **General Hooks:** `src/hooks/*`

#### Services
- **Location:** `src/services/*`
- **Naming:** `*.service.ts`

#### Types
- **Location:** `src/types/*`
- **Naming:** `*.ts` (e.g., `admin.ts`, `product.ts`)

---

## 📁 Manual Testing Files Storage

### Location: `/manual-testing/`

```
manual-testing/
├── 00_README.md                        # Overview guide
├── INDEX.md                            # Complete index
├── FILE_STORAGE_STRUCTURE.md           # This file
├── ADMIN_CREATION_FLOW.md              # Admin creation documentation
│
├── 01_Login_Authentication.md         # Login & auth tests
├── 02_Dashboard.md                     # Dashboard tests
├── 03_Admin_Management.md            # Admin management tests
├── 04_User_Management.md               # User management tests
├── 05_Supplier_Management.md          # Supplier management tests
├── 06_Product_Management.md            # Product management tests
├── 07_Order_Management.md              # Order management tests
│
├── 08_Reports_Analytics.md             # Reports tests (TO CREATE)
├── 09_System_Settings.md                # Settings tests (TO CREATE)
├── 10_Promotions_Coupons.md            # Promotions tests (TO CREATE)
├── 11_Support_Tickets.md               # Support tests (TO CREATE)
└── 12_RBAC_Permissions.md              # RBAC tests (TO CREATE)
```

### Manual Testing File Naming Convention

- **Format:** `NN_Feature_Name.md`
- **NN:** Two-digit number (00-99) for ordering
- **Feature_Name:** PascalCase or underscore_case
- **Extension:** `.md`

**Examples:**
- `00_README.md`
- `01_Login_Authentication.md`
- `03_Admin_Management.md`

---

## 📁 Documentation Files Storage

### Location: `/docs/` (if exists) or root level

```
docs/                                   # Project documentation
├── ADMIN_SYSTEM_ARCHITECTURE.md
├── ADMIN_FEATURES_BY_ROLE.md
├── COMPLETE_FEATURE_LIST.md
├── ROUTES_CLEANUP_SUMMARY.md
└── ...
```

---

## 📝 File Naming Conventions

### Backend (Rails)

#### Controllers
- **Format:** `snake_case_controller.rb`
- **Examples:**
  - `admins_controller.rb`
  - `users_controller.rb`
  - `product_variants_controller.rb`

#### Models
- **Format:** `snake_case.rb`
- **Examples:**
  - `admin.rb`
  - `user.rb`
  - `supplier_profile.rb`

#### Services
- **Format:** `*_service.rb`
- **Examples:**
  - `password_hashing_service.rb`
  - `email_verification_service.rb`

#### Views
- **Format:** `snake_case.html.erb`
- **Examples:**
  - `index.html.erb`
  - `show.html.erb`
  - `_form.html.erb` (partials)

#### Tests
- **Format:** `*_spec.rb`
- **Examples:**
  - `admin_spec.rb`
  - `admins_controller_spec.rb`

### Frontend (React/TypeScript)

#### Components
- **Format:** `PascalCase.tsx`
- **Examples:**
  - `AdminLogin.tsx`
  - `ProductCard.tsx`
  - `OrderCard.tsx`

#### Pages
- **Format:** `PascalCase.tsx`
- **Examples:**
  - `Dashboard.tsx`
  - `Users.tsx`
  - `ProductDetail.tsx`

#### Hooks
- **Format:** `use*.ts` or `use*.tsx`
- **Examples:**
  - `useAuth.ts`
  - `useAdminUsers.ts`
  - `useCart.ts`

#### Services
- **Format:** `*.service.ts`
- **Examples:**
  - `auth.service.ts`
  - `products.service.ts`

#### Types
- **Format:** `*.ts`
- **Examples:**
  - `admin.ts`
  - `product.ts`
  - `order.ts`

#### Contexts
- **Format:** `*Context.tsx`
- **Examples:**
  - `UserContext.tsx`
  - `AdminContext.tsx`

---

## 🔄 File Generation Rules

### When Creating New Files

#### Backend Files

1. **Controller:**
   - Location: `app/controllers/admin/` or `app/controllers/api/v1/`
   - Naming: `*_controller.rb`
   - Test: Create corresponding `*_spec.rb` in `spec/controllers/`

2. **Model:**
   - Location: `app/models/`
   - Naming: `snake_case.rb`
   - Test: Create `*_spec.rb` in `spec/models/`
   - Migration: Create migration in `db/migrate/`

3. **Service:**
   - Location: `app/services/`
   - Naming: `*_service.rb`
   - Test: Create `*_spec.rb` in `spec/services/`

4. **View:**
   - Location: `app/views/admin/*/` or `app/views/*_mailer/`
   - Naming: `snake_case.html.erb`

#### Frontend Files

1. **Component:**
   - Location: `src/components/admin/`, `src/components/supplier/`, etc.
   - Naming: `PascalCase.tsx`
   - Test: Create `*.test.tsx` or `*.spec.tsx` (if testing)

2. **Page:**
   - Location: `src/pages/admin/`, `src/pages/supplier/`, etc.
   - Naming: `PascalCase.tsx`
   - Add route in `src/router.tsx`

3. **Hook:**
   - Location: `src/hooks/admin/`, `src/hooks/supplier/`, etc.
   - Naming: `use*.ts`
   - Export from `src/hooks/index.ts` (if exists)

4. **Service:**
   - Location: `src/services/`
   - Naming: `*.service.ts`
   - Import in `src/services/api.ts` if needed

5. **Type:**
   - Location: `src/types/`
   - Naming: `*.ts`
   - Export types for use in components

---

## 📦 File Organization Best Practices

### Backend

1. **Keep controllers thin** - Move business logic to services
2. **Group related models** - Use concerns for shared behavior
3. **Organize services by domain** - Group related services
4. **Follow REST conventions** - Standard controller actions
5. **Use namespaces** - `Admin::`, `Api::V1::` for organization

### Frontend

1. **Feature-based organization** - Group by feature (admin, supplier, customer)
2. **Component co-location** - Keep related components together
3. **Shared components** - Put reusable components in `ui/` or `common/`
4. **Type safety** - Define types in `types/` directory
5. **Service layer** - Abstract API calls in services

---

## 🔍 Finding Files

### Backend Files

```bash
# Find controller
find luxe-threads-backend/app/controllers -name "*admin*controller.rb"

# Find model
find luxe-threads-backend/app/models -name "admin.rb"

# Find service
find luxe-threads-backend/app/services -name "*service.rb"

# Find view
find luxe-threads-backend/app/views -name "*.html.erb"
```

### Frontend Files

```bash
# Find component
find luxethreads/src/components -name "Admin*.tsx"

# Find page
find luxethreads/src/pages -name "*.tsx"

# Find hook
find luxethreads/src/hooks -name "use*.ts"

# Find service
find luxethreads/src/services -name "*.service.ts"
```

---

## 📋 File Checklist

When creating a new feature, ensure:

### Backend
- [ ] Controller created in correct namespace
- [ ] Model created with validations
- [ ] Migration created and run
- [ ] Routes added to `config/routes.rb`
- [ ] Service created (if business logic needed)
- [ ] Tests created (model, controller, service)
- [ ] Factory created (if needed)
- [ ] View created (if HTML interface)

### Frontend
- [ ] Component/Page created
- [ ] Types defined
- [ ] Service created (if API calls needed)
- [ ] Hook created (if state management needed)
- [ ] Route added to router
- [ ] Context updated (if global state needed)
- [ ] UI components used from `ui/` directory

---

## 🗂️ Future File Additions

### Planned Backend Files
- Additional admin controllers
- New service classes
- Background jobs
- Mailers
- Policies (authorization)

### Planned Frontend Files
- Additional admin pages
- New components
- More hooks
- Additional services
- New types

**All future files should follow the structure and naming conventions defined in this document.**

---

## 📝 Notes

- **Keep files organized** by feature/domain
- **Use consistent naming** across the project
- **Follow Rails conventions** for backend
- **Follow React/TypeScript conventions** for frontend
- **Document file purposes** in code comments
- **Update this document** when adding new file types or structures

---

**Last Updated:** 2025-01-18  
**Version:** 1.0  
**Maintained By:** Development Team

