# Complete Admin Functionality Guide

## Table of Contents

**Part 1: Overview & Authentication**
- Admin System Architecture
- Authentication & Authorization
- Admin Roles & Permissions

**Part 2: Core Admin Features**
- Dashboard & Analytics
- User Management
- Supplier Management
- Product Management

**Part 3: Advanced Admin Features**
- Order Management
- Reports & Analytics
- Settings & Configuration
- RBAC & Permissions Management

**Part 4: API Endpoints & Integration**
- Admin API Endpoints
- Frontend-Backend Integration
- Testing & Verification

---

# Part 1: Overview & Authentication

## 1.1 Admin System Architecture

The admin system has **two interfaces**:

### A. HTML Interface (Backend Admin Panel)
- **Base URL**: `/admin/*`
- **Purpose**: Full-featured admin panel with HTML views
- **Controllers**: `app/controllers/admin/*`
- **Views**: `app/views/admin/*`
- **Authentication**: Session-based (cookies)

### B. API Interface (REST API)
- **Base URL**: `/api/v1/admin/*`
- **Purpose**: RESTful API for frontend admin panel
- **Controllers**: `app/controllers/api/v1/admin/*`
- **Authentication**: JWT tokens (cookies or Authorization header)

## 1.2 Admin Roles

The system supports **5 admin roles**:

1. **Super Admin** (`super_admin`)
   - Full system access
   - Can manage all admins
   - Can manage settings, email templates, navigation
   - Can manage RBAC roles and permissions

2. **Product Admin** (`product_admin`)
   - Manage products and categories
   - Approve/reject products
   - View product reports

3. **Order Admin** (`order_admin`)
   - Manage orders
   - Update order status
   - Process refunds
   - View order reports

4. **User Admin** (`user_admin`)
   - Manage users/customers
   - View user activity
   - Manage user accounts

5. **Supplier Admin** (`supplier_admin`)
   - Manage suppliers
   - Approve/reject suppliers
   - View supplier reports

## 1.3 Authentication Flow

### HTML Interface Login

**Route**: `POST /admin/login`

**Flow**:
1. Admin enters email and password
2. System validates credentials
3. Creates session (cookie-based)
4. Redirects to dashboard
5. Session persists until logout or expiry

**Controller**: `Admin::SessionsController`

**Features**:
- Remember me functionality
- Failed login attempt tracking
- Account lockout after multiple failures
- Password reset via email

### API Interface Login

**Route**: `POST /api/v1/admin/login`

**Flow**:
1. Frontend sends email and password
2. Backend validates credentials
3. Returns JWT token in httpOnly cookie
4. Frontend stores token (automatic via cookie)
5. Subsequent requests include token automatically

**Controller**: `Api::V1::Admin::AuthenticationController`

**Response Format**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "admin": {
      "id": 1,
      "email": "admin@example.com",
      "first_name": "Admin",
      "role": "super_admin",
      "permissions": [...]
    }
  }
}
```

## 1.4 Authorization & Permissions

### Role-Based Access Control (RBAC)

The system uses **two authorization layers**:

#### Layer 1: Enum-Based Roles (Legacy)
- Simple role checking: `admin.super_admin?`, `admin.product_admin?`
- Used for basic access control
- Methods: `can_manage_products?`, `can_manage_orders?`, etc.

#### Layer 2: RBAC System (Advanced)
- Database-driven roles and permissions
- Fine-grained permission control
- Multiple roles per admin
- Dynamic permission assignment

**RBAC Components**:
- **Roles**: Collections of permissions (e.g., "Product Manager")
- **Permissions**: Specific actions (e.g., `products:create`, `orders:view`)
- **Role Assignments**: Links admins to roles

**Permission Format**: `resource:action`
- Examples: `products:view`, `products:create`, `orders:update`, `users:delete`

### Authorization Checks

**In Controllers**:
```ruby
# Check if admin can manage products
before_action :require_product_admin!, only: [:create, :update]

# Check specific permission
before_action :require_permission!, only: [:destroy], permission: 'products:delete'

# Check super admin
before_action :require_super_admin!, only: [:settings]
```

**In Views**:
```erb
<% if current_admin.can_manage_products? %>
  <%= link_to "Manage Products", admin_products_path %>
<% end %>
```

## 1.5 Admin Model

**Location**: `app/models/admin.rb`

**Key Attributes**:
- `email`: Unique email address
- `first_name`, `last_name`: Admin name
- `role`: Enum role (super_admin, product_admin, etc.)
- `is_active`: Account active status
- `is_blocked`: Account blocked status
- `last_login_at`: Last login timestamp
- `permissions`: JSON permissions (legacy)

**Key Methods**:
- `can_manage_products?`: Check product management access
- `can_manage_orders?`: Check order management access
- `can_manage_users?`: Check user management access
- `can_manage_suppliers?`: Check supplier management access
- `has_permission?(permission)`: Check specific permission
- `block!`: Block admin account
- `unblock!`: Unblock admin account
- `update_last_login!`: Update last login timestamp

**Associations**:
- `has_many :admin_role_assignments`: RBAC role assignments
- `has_many :rbac_roles`: Assigned RBAC roles
- `has_many :admin_activities`: Activity log
- `belongs_to :invited_by`: Admin who invited this admin

---

# Part 2: Core Admin Features

## 2.1 Dashboard

### HTML Interface
**Route**: `GET /admin/dashboard`
**Controller**: `Admin::DashboardController#index`
**View**: `app/views/admin/dashboard.html.erb`

### API Interface
**Route**: `GET /api/v1/admin/dashboard` (if implemented)
**Controller**: `Admin::DashboardController` (API version)

### Features
- **Revenue Metrics**: Total revenue, daily revenue, revenue by category
- **Statistics Cards**: Users, orders, products, suppliers counts
- **Charts**: Revenue trends, category distribution
- **Notifications**: Pending orders, products awaiting approval, low stock alerts
- **Quick Actions**: Common admin tasks
- **Date Range Filtering**: Filter metrics by date range

### Data Provided
```ruby
@stats = {
  total_users: User.count,
  total_orders: Order.count,
  total_products: Product.count,
  total_suppliers: SupplierProfile.count,
  pending_orders: Order.pending.count,
  pending_products: Product.pending_approval.count
}

@revenue_metrics = {
  total_revenue: Order.completed.sum(:total_amount),
  today_revenue: Order.completed.where(created_at: Date.today).sum(:total_amount),
  monthly_revenue: Order.completed.where(created_at: 1.month.ago..).sum(:total_amount)
}
```

## 2.2 User Management

### HTML Interface Routes
- `GET /admin/users` - List all users
- `GET /admin/users/:id` - View user details
- `GET /admin/users/:id/edit` - Edit user
- `PATCH /admin/users/:id` - Update user
- `DELETE /admin/users/:id` - Delete user
- `PATCH /admin/users/:id/status` - Update user status
- `GET /admin/users/:id/orders` - View user orders
- `GET /admin/users/:id/activity` - View user activity
- `POST /admin/users/bulk_action` - Bulk actions

### API Interface Routes
- `GET /api/v1/admin/users` - List users
- `GET /api/v1/admin/users/:id` - Get user
- `PATCH /api/v1/admin/users/:id` - Update user
- `DELETE /api/v1/admin/users/:id` - Delete user
- `PATCH /api/v1/admin/users/:id/status` - Update status
- `GET /api/v1/admin/users/:id/orders` - Get user orders
- `GET /api/v1/admin/users/:id/activity` - Get user activity

### Features
- **View Users**: List all users with search and filters
- **User Details**: View complete user profile
- **Edit User**: Update user information
- **Status Management**: Activate/deactivate users
- **Order History**: View all orders by user
- **Activity Log**: View user activity history
- **Bulk Actions**: Bulk activate/deactivate/delete

### Permissions Required
- `users:view` - View users
- `users:update` - Edit users
- `users:delete` - Delete users
- `users:manage_status` - Change user status

## 2.3 Supplier Management

### HTML Interface Routes
- `GET /admin/suppliers` - List suppliers
- `GET /admin/suppliers/:id` - View supplier
- `GET /admin/suppliers/new` - Create supplier
- `POST /admin/suppliers` - Create supplier
- `GET /admin/suppliers/:id/edit` - Edit supplier
- `PATCH /admin/suppliers/:id` - Update supplier
- `DELETE /admin/suppliers/:id` - Delete supplier
- `GET /admin/suppliers/invite` - Invite supplier form
- `POST /admin/suppliers/send_invitation` - Send invitation
- `PATCH /admin/suppliers/:id/status` - Update status
- `PATCH /admin/suppliers/:id/suspend` - Suspend supplier
- `POST /admin/suppliers/:id/approve` - Approve supplier
- `POST /admin/suppliers/:id/reject` - Reject supplier
- `GET /admin/suppliers/:id/stats` - Supplier statistics
- `POST /admin/suppliers/:id/resend_invitation` - Resend invitation
- `POST /admin/suppliers/bulk_action` - Bulk actions

### API Interface Routes
- `GET /api/v1/admin/suppliers` - List suppliers
- `GET /api/v1/admin/suppliers/:id` - Get supplier
- `PATCH /api/v1/admin/suppliers/:id` - Update supplier
- `DELETE /api/v1/admin/suppliers/:id` - Delete supplier
- `POST /api/v1/admin/suppliers/invite` - Invite supplier
- `PATCH /api/v1/admin/suppliers/:id/status` - Update status
- `PATCH /api/v1/admin/suppliers/:id/suspend` - Suspend supplier
- `GET /api/v1/admin/suppliers/:id/stats` - Get supplier stats
- `POST /api/v1/admin/suppliers/:id/resend_invitation` - Resend invitation

### Features
- **View Suppliers**: List all suppliers
- **Supplier Details**: View complete supplier profile
- **Create Supplier**: Add new supplier
- **Edit Supplier**: Update supplier information
- **Invite Supplier**: Send invitation email
- **Approve/Reject**: Approve or reject supplier applications
- **Suspend Supplier**: Temporarily suspend supplier
- **Status Management**: Activate/deactivate suppliers
- **Supplier Stats**: View supplier performance metrics
- **Bulk Actions**: Bulk approve/reject/suspend

### Permissions Required
- `suppliers:view` - View suppliers
- `suppliers:create` - Create suppliers
- `suppliers:update` - Edit suppliers
- `suppliers:delete` - Delete suppliers
- `suppliers:approve` - Approve suppliers
- `suppliers:suspend` - Suspend suppliers

## 2.4 Product Management

### HTML Interface Routes
- `GET /admin/products` - List products
- `GET /admin/products/:id` - View product
- `GET /admin/products/:id/edit` - Edit product
- `PATCH /admin/products/:id` - Update product
- `DELETE /admin/products/:id` - Delete product
- `PATCH /admin/products/:id/approve` - Approve product
- `PATCH /admin/products/:id/reject` - Reject product
- `POST /admin/products/bulk_approve` - Bulk approve
- `POST /admin/products/bulk_reject` - Bulk reject
- `GET /admin/products/export` - Export products

### API Interface Routes
- `GET /api/v1/admin/products` - List products
- `GET /api/v1/admin/products/:id` - Get product
- `PATCH /api/v1/admin/products/:id` - Update product
- `DELETE /api/v1/admin/products/:id` - Delete product
- `PATCH /api/v1/admin/products/:id/approve` - Approve product
- `PATCH /api/v1/admin/products/:id/reject` - Reject product
- `POST /api/v1/admin/products/bulk_approve` - Bulk approve
- `POST /api/v1/admin/products/bulk_reject` - Bulk reject
- `GET /api/v1/admin/products/export` - Export products

### Features
- **View Products**: List all products with filters
- **Product Details**: View complete product information
- **Edit Product**: Update product details
- **Approve Products**: Approve pending products
- **Reject Products**: Reject products with reason
- **Bulk Operations**: Bulk approve/reject products
- **Export Products**: Export product data (CSV/Excel)
- **Product Search**: Search products by name, SKU, etc.
- **Category Filtering**: Filter by category
- **Status Filtering**: Filter by approval status

### Product Approval Workflow
1. Supplier creates product → Status: `pending_approval`
2. Admin reviews product
3. Admin approves → Status: `approved` → Product visible
4. OR Admin rejects → Status: `rejected` → Product hidden

### Permissions Required
- `products:view` - View products
- `products:update` - Edit products
- `products:delete` - Delete products
- `products:approve` - Approve products
- `products:reject` - Reject products

---

# Part 3: Advanced Admin Features

## 3.1 Order Management

### HTML Interface Routes
- `GET /admin/orders` - List orders
- `GET /admin/orders/:id` - View order
- `GET /admin/orders/:id/edit` - Edit order
- `PATCH /admin/orders/:id` - Update order
- `DELETE /admin/orders/:id` - Delete order
- `PATCH /admin/orders/:id/cancel` - Cancel order
- `PATCH /admin/orders/:id/update_status` - Update order status
- `POST /admin/orders/:id/notes` - Add order note
- `GET /admin/orders/:id/audit_log` - View audit log
- `PATCH /admin/orders/:id/refund` - Process refund

### API Interface Routes
- `GET /api/v1/admin/orders` - List orders
- `GET /api/v1/admin/orders/:id` - Get order
- `PATCH /api/v1/admin/orders/:id` - Update order
- `DELETE /api/v1/admin/orders/:id` - Delete order
- `PATCH /api/v1/admin/orders/:id/cancel` - Cancel order
- `PATCH /api/v1/admin/orders/:id/update_status` - Update status
- `POST /api/v1/admin/orders/:id/notes` - Add note
- `GET /api/v1/admin/orders/:id/audit_log` - Get audit log
- `PATCH /api/v1/admin/orders/:id/refund` - Process refund

### Features
- **View Orders**: List all orders with filters
- **Order Details**: View complete order information
- **Update Status**: Change order status (pending, processing, shipped, delivered, cancelled)
- **Cancel Orders**: Cancel orders with reason
- **Process Refunds**: Refund orders
- **Order Notes**: Add internal notes to orders
- **Audit Log**: View order history and changes
- **Order Search**: Search by order number, customer, etc.
- **Status Filtering**: Filter by order status
- **Date Filtering**: Filter by order date

### Order Statuses
- `pending` - Order placed, awaiting payment
- `paid` - Payment received
- `processing` - Order being prepared
- `shipped` - Order shipped
- `delivered` - Order delivered
- `cancelled` - Order cancelled
- `refunded` - Order refunded

### Permissions Required
- `orders:view` - View orders
- `orders:update` - Edit orders
- `orders:delete` - Delete orders
- `orders:cancel` - Cancel orders
- `orders:refund` - Process refunds

## 3.2 Reports & Analytics

### HTML Interface Routes
- `GET /admin/reports` - Reports dashboard
- `GET /admin/reports/sales` - Sales report
- `GET /admin/reports/products` - Products report
- `GET /admin/reports/users` - Users report
- `GET /admin/reports/suppliers` - Suppliers report
- `GET /admin/reports/revenue` - Revenue report
- `GET /admin/reports/returns` - Returns report
- `GET /admin/reports/export` - Export reports

### API Interface Routes
- `GET /api/v1/admin/reports/sales` - Sales report
- `GET /api/v1/admin/reports/products` - Products report
- `GET /api/v1/admin/reports/users` - Users report
- `GET /api/v1/admin/reports/suppliers` - Suppliers report
- `GET /api/v1/admin/reports/revenue` - Revenue report
- `GET /api/v1/admin/reports/returns` - Returns report
- `GET /api/v1/admin/reports/export` - Export reports

### Report Types

#### Sales Report
- Total sales by period
- Sales by product
- Sales by category
- Sales by supplier
- Revenue trends
- Top selling products

#### Products Report
- Product performance
- Low stock alerts
- Products by category
- Products by supplier
- Approval status breakdown

#### Users Report
- User registration trends
- Active vs inactive users
- User activity metrics
- User acquisition sources

#### Suppliers Report
- Supplier performance
- Supplier approval status
- Products per supplier
- Revenue by supplier

#### Revenue Report
- Total revenue
- Revenue by period (daily, weekly, monthly)
- Revenue by category
- Revenue trends and forecasts

#### Returns Report
- Return requests
- Return reasons
- Refund amounts
- Return trends

### Features
- **Date Range Filtering**: Filter reports by date range
- **Export Options**: Export to CSV, Excel, PDF
- **Charts & Graphs**: Visual representation of data
- **Real-time Data**: Live data updates
- **Scheduled Reports**: Email reports on schedule

## 3.3 Settings & Configuration

### HTML Interface Routes (Super Admin Only)
- `GET /admin/settings` - List settings
- `GET /admin/settings/:id` - View setting
- `GET /admin/settings/new` - Create setting
- `POST /admin/settings` - Create setting
- `GET /admin/settings/:id/edit` - Edit setting
- `PATCH /admin/settings/:id` - Update setting
- `DELETE /admin/settings/:id` - Delete setting

### API Interface Routes (Super Admin Only)
- `GET /api/v1/admin/settings` - List settings
- `GET /api/v1/admin/settings/:key` - Get setting by key
- `POST /api/v1/admin/settings` - Create setting
- `PATCH /api/v1/admin/settings/:id` - Update setting
- `DELETE /api/v1/admin/settings/:id` - Delete setting

### System Configurations
- `GET /admin/system_configurations` - List configurations
- `PATCH /admin/system_configurations/:id/activate` - Activate
- `PATCH /admin/system_configurations/:id/deactivate` - Deactivate

### Email Templates (Super Admin Only)
- `GET /admin/email_templates` - List templates
- `GET /admin/email_templates/:id` - View template
- `GET /admin/email_templates/new` - Create template
- `POST /admin/email_templates` - Create template
- `GET /admin/email_templates/:id/edit` - Edit template
- `PATCH /admin/email_templates/:id` - Update template
- `DELETE /admin/email_templates/:id` - Delete template
- `POST /admin/email_templates/:id/preview` - Preview template

### Navigation Items (Super Admin Only)
- `GET /admin/navigation_items` - List navigation items
- `GET /admin/navigation_items/:id` - View item
- `GET /admin/navigation_items/new` - Create item
- `POST /admin/navigation_items` - Create item
- `GET /admin/navigation_items/:id/edit` - Edit item
- `PATCH /admin/navigation_items/:id` - Update item
- `DELETE /admin/navigation_items/:id` - Delete item

### Features
- **Application Settings**: General application configuration
- **Email Settings**: SMTP and email configuration
- **Payment Settings**: Payment gateway configuration
- **Shipping Settings**: Shipping method configuration
- **Feature Flags**: Enable/disable features
- **Email Templates**: Manage email templates
- **Navigation Management**: Dynamic navigation configuration

## 3.4 RBAC & Permissions Management

### HTML Interface Routes (Super Admin Only)
- `GET /admin/roles-permissions` - List roles
- `GET /admin/roles-permissions/:id` - View role
- `GET /admin/roles-permissions/:id/edit` - Edit role
- `PATCH /admin/roles-permissions/:id` - Update role
- `POST /admin/roles-permissions/:id/assign_to_admin` - Assign role
- `DELETE /admin/roles-permissions/:id/remove_from_admin` - Remove role

### API Interface Routes (Super Admin Only)
- `GET /api/v1/admin/rbac/roles` - List roles
- `GET /api/v1/admin/rbac/permissions` - List permissions
- `GET /api/v1/admin/rbac/admins/:id/roles` - Get admin roles
- `POST /api/v1/admin/rbac/admins/:id/assign_role` - Assign role
- `DELETE /api/v1/admin/rbac/admins/:id/remove_role/:role_slug` - Remove role
- `PATCH /api/v1/admin/rbac/admins/:id/update_permissions` - Update permissions

### Features
- **Role Management**: Create, edit, delete roles
- **Permission Management**: View all available permissions
- **Role Assignment**: Assign roles to admins
- **Permission Assignment**: Assign specific permissions to admins
- **Role Hierarchy**: Define role priorities
- **Permission Inheritance**: Roles inherit permissions

### RBAC Workflow
1. Super Admin creates role (e.g., "Product Manager")
2. Assigns permissions to role (e.g., `products:view`, `products:create`)
3. Assigns role to admin
4. Admin inherits all permissions from role
5. Can also assign individual permissions directly

---

# Part 4: API Endpoints & Integration

## 4.1 Complete API Endpoint List

### Authentication
```
POST   /api/v1/admin/login          - Admin login
DELETE /api/v1/admin/logout         - Admin logout
GET    /api/v1/admin/me             - Get current admin
```

### Admin Management (Super Admin Only)
```
GET    /api/v1/admin/admins         - List admins
GET    /api/v1/admin/admins/:id     - Get admin
PATCH  /api/v1/admin/admins/:id     - Update admin
DELETE /api/v1/admin/admins/:id     - Delete admin
PATCH  /api/v1/admin/admins/:id/block      - Block admin
PATCH  /api/v1/admin/admins/:id/unblock    - Unblock admin
PATCH  /api/v1/admin/admins/:id/status     - Update status
```

### User Management
```
GET    /api/v1/admin/users           - List users
GET    /api/v1/admin/users/:id      - Get user
PATCH  /api/v1/admin/users/:id      - Update user
DELETE /api/v1/admin/users/:id      - Delete user
PATCH  /api/v1/admin/users/:id/status      - Update status
GET    /api/v1/admin/users/:id/orders      - Get user orders
GET    /api/v1/admin/users/:id/activity    - Get user activity
```

### Supplier Management
```
GET    /api/v1/admin/suppliers      - List suppliers
GET    /api/v1/admin/suppliers/:id  - Get supplier
PATCH  /api/v1/admin/suppliers/:id  - Update supplier
DELETE /api/v1/admin/suppliers/:id  - Delete supplier
POST   /api/v1/admin/suppliers/invite       - Invite supplier
PATCH  /api/v1/admin/suppliers/:id/status   - Update status
PATCH  /api/v1/admin/suppliers/:id/suspend  - Suspend supplier
GET    /api/v1/admin/suppliers/:id/stats    - Get stats
POST   /api/v1/admin/suppliers/:id/resend_invitation - Resend invitation
```

### Product Management
```
GET    /api/v1/admin/products       - List products
GET    /api/v1/admin/products/:id  - Get product
PATCH  /api/v1/admin/products/:id  - Update product
DELETE /api/v1/admin/products/:id  - Delete product
PATCH  /api/v1/admin/products/:id/approve   - Approve product
PATCH  /api/v1/admin/products/:id/reject    - Reject product
POST   /api/v1/admin/products/bulk_approve  - Bulk approve
POST   /api/v1/admin/products/bulk_reject   - Bulk reject
GET    /api/v1/admin/products/export        - Export products
```

### Order Management
```
GET    /api/v1/admin/orders         - List orders
GET    /api/v1/admin/orders/:id     - Get order
PATCH  /api/v1/admin/orders/:id     - Update order
DELETE /api/v1/admin/orders/:id     - Delete order
PATCH  /api/v1/admin/orders/:id/cancel      - Cancel order
PATCH  /api/v1/admin/orders/:id/update_status - Update status
POST   /api/v1/admin/orders/:id/notes      - Add note
GET    /api/v1/admin/orders/:id/audit_log  - Get audit log
PATCH  /api/v1/admin/orders/:id/refund     - Process refund
```

### Reports
```
GET    /api/v1/admin/reports/sales      - Sales report
GET    /api/v1/admin/reports/products   - Products report
GET    /api/v1/admin/reports/users      - Users report
GET    /api/v1/admin/reports/suppliers  - Suppliers report
GET    /api/v1/admin/reports/revenue    - Revenue report
GET    /api/v1/admin/reports/returns    - Returns report
GET    /api/v1/admin/reports/export     - Export reports
```

### Settings (Super Admin Only)
```
GET    /api/v1/admin/settings       - List settings
GET    /api/v1/admin/settings/:key - Get setting
POST   /api/v1/admin/settings      - Create setting
PATCH  /api/v1/admin/settings/:id  - Update setting
DELETE /api/v1/admin/settings/:id  - Delete setting
```

### Email Templates (Super Admin Only)
```
GET    /api/v1/admin/email_templates        - List templates
GET    /api/v1/admin/email_templates/:id     - Get template
POST   /api/v1/admin/email_templates        - Create template
PATCH  /api/v1/admin/email_templates/:id    - Update template
DELETE /api/v1/admin/email_templates/:id    - Delete template
POST   /api/v1/admin/email_templates/:id/preview - Preview template
```

### RBAC (Super Admin Only)
```
GET    /api/v1/admin/rbac/roles                    - List roles
GET    /api/v1/admin/rbac/permissions               - List permissions
GET    /api/v1/admin/rbac/admins/:id/roles         - Get admin roles
POST   /api/v1/admin/rbac/admins/:id/assign_role   - Assign role
DELETE /api/v1/admin/rbac/admins/:id/remove_role/:role_slug - Remove role
PATCH  /api/v1/admin/rbac/admins/:id/update_permissions - Update permissions
```

### Search
```
GET    /api/v1/admin/search?q=query - Unified search
```

## 4.2 Frontend-Backend Integration

### Authentication Flow

1. **Login Request**:
```javascript
POST /api/v1/admin/login
Body: { email: "admin@example.com", password: "password" }
Response: { success: true, data: { admin: {...} } }
Cookie: admin_token (httpOnly, secure)
```

2. **Authenticated Requests**:
```javascript
// Token automatically sent in cookie
GET /api/v1/admin/users
Headers: Cookie: admin_token=...
Response: { success: true, data: [...] }
```

3. **Logout**:
```javascript
DELETE /api/v1/admin/logout
Response: { success: true, message: "Logged out" }
Cookie: admin_token (deleted)
```

### Error Handling

**401 Unauthorized**:
```json
{
  "success": false,
  "message": "Authentication required",
  "error_code": "UNAUTHORIZED"
}
```

**403 Forbidden**:
```json
{
  "success": false,
  "message": "You don't have permission to perform this action",
  "error_code": "FORBIDDEN"
}
```

**404 Not Found**:
```json
{
  "success": false,
  "message": "Resource not found",
  "error_code": "NOT_FOUND"
}
```

## 4.3 Testing & Verification

### Test Admin Login
```bash
curl -X POST http://localhost:3000/api/v1/admin/login \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:8080" \
  -d '{"email":"admin@example.com","password":"password"}' \
  -c cookies.txt -v
```

### Test Authenticated Request
```bash
curl -X GET http://localhost:3000/api/v1/admin/users \
  -H "Origin: http://localhost:8080" \
  -b cookies.txt -v
```

### Test Permission Check
```bash
# As non-super admin trying to access super admin endpoint
curl -X GET http://localhost:3000/api/v1/admin/settings \
  -H "Origin: http://localhost:8080" \
  -b cookies.txt -v
# Should return 403 Forbidden
```

---

## Summary

The admin system provides:

✅ **Dual Interface**: HTML panel + REST API
✅ **5 Admin Roles**: Super Admin, Product Admin, Order Admin, User Admin, Supplier Admin
✅ **RBAC System**: Fine-grained permissions
✅ **Complete CRUD**: All resources manageable
✅ **Reports & Analytics**: Comprehensive reporting
✅ **Audit Logging**: Track all admin actions
✅ **Secure Authentication**: JWT tokens + sessions
✅ **Permission-Based Access**: Role and permission checks

All functionality is production-ready and fully integrated with the backend application.

