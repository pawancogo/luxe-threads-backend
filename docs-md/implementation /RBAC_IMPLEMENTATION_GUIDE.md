# RBAC Implementation Guide

## Overview

This document explains the **Role-Based Access Control (RBAC)** system, **Permissions**, and **Navigation Items** in the LuxeThreads e-commerce platform. These three systems work together to provide fine-grained access control and dynamic UI management.

## Table of Contents

1. [Understanding the Three Components](#understanding-the-three-components)
2. [How They Work Together](#how-they-work-together)
3. [Database Schema](#database-schema)
4. [Models and Services](#models-and-services)
5. [Navigation Items System](#navigation-items-system)
6. [Usage Examples](#usage-examples)
7. [Common Workflows](#common-workflows)
8. [Adding New Roles, Permissions, or Navigation Items](#adding-new-roles-permissions-or-navigation-items)

---

## Understanding the Three Components

### 1. **Roles** (`RbacRole`)

**What it is:** A role is a collection of permissions that defines what a user can do in the system.

**Examples:**
- `super_admin` - Has all permissions
- `product_admin` - Can manage products, categories
- `order_manager` - Can view and manage orders
- `supplier_owner` - Supplier account owner with full access

**Key Properties:**
- `name`: Human-readable name (e.g., "Product Admin")
- `slug`: Unique identifier (e.g., "product_admin")
- `role_type`: Either `admin`, `supplier`, or `system`
- `priority`: Used to determine primary role when user has multiple roles
- `is_system`: System roles cannot be deleted

**Where it's stored:** `rbac_roles` table

### 2. **Permissions** (`RbacPermission`)

**What it is:** A permission is a specific action that can be performed on a resource.

**Format:** `resource:action` (e.g., `products:create`, `orders:view`)

**Examples:**
- `products:view` - Can view products
- `products:create` - Can create products
- `products:update` - Can update products
- `products:delete` - Can delete products
- `orders:view` - Can view orders
- `orders:update` - Can update orders

**Key Properties:**
- `slug`: The permission identifier (e.g., "products:create")
- `name`: Human-readable name (e.g., "Create Products")
- `resource_type`: The resource (e.g., "products", "orders")
- `action`: The action (e.g., "view", "create", "update", "delete")
- `category`: Groups related permissions (e.g., "Product Management")

**Where it's stored:** `rbac_permissions` table

**How roles get permissions:** Through the `rbac_role_permissions` join table

### 3. **Navigation Items** (`NavigationItem`)

**What it is:** A navigation item represents a menu item in the admin panel that can be shown or hidden based on user permissions.

**Examples:**
- "Products" menu item
- "Orders" menu item
- "Customers" menu item

**Key Properties:**
- `key`: Unique identifier (e.g., "products", "orders")
- `label`: Display name (e.g., "Products", "Orders")
- `icon`: Font Awesome icon class
- `path_method`: Route helper (e.g., "admin_products_path")
- `section`: Groups items (e.g., "Product Management", "User Management")
- `required_permissions`: JSON array of permission slugs needed to view this item
- `view_permissions`: Permissions needed to view
- `create_permissions`: Permissions needed to create
- `edit_permissions`: Permissions needed to edit
- `delete_permissions`: Permissions needed to delete
- `require_super_admin`: If true, only super admins can see this
- `always_visible`: If true, always shown (e.g., Dashboard)
- `is_system`: System items cannot be deleted

**Where it's stored:** `navigation_items` table

---

## How They Work Together

Here's the flow of how these three components work together:

```
┌─────────────────┐
│   Admin User    │
└────────┬────────┘
         │
         │ Has assigned
         ▼
┌─────────────────┐
│   RBAC Roles     │  (e.g., product_admin)
└────────┬────────┘
         │
         │ Contains
         ▼
┌─────────────────┐
│  Permissions    │  (e.g., products:view, products:create)
└────────┬────────┘
         │
         │ Used to check
         ▼
┌─────────────────┐
│ Navigation Items│  (e.g., "Products" menu)
└─────────────────┘
```

### Example Flow:

1. **Admin logs in** → System checks their assigned roles
2. **Roles provide permissions** → Admin with `product_admin` role gets `products:view`, `products:create`, etc.
3. **Navigation items check permissions** → "Products" menu item requires `products:view` permission
4. **Menu is shown/hidden** → If admin has `products:view`, they see the "Products" menu item

### Real Example:

```ruby
# Admin: john@example.com
# Assigned Role: product_admin
# Role Permissions: products:view, products:create, products:update, categories:view

# Navigation Item: "Products"
# Required Permissions: ['products:view', 'products:read']

# Result: Admin sees "Products" menu because they have products:view permission
```

---

## Database Schema

### Core Tables

#### `rbac_roles`
Stores all roles in the system.

```ruby
# Example records:
# id: 1, name: "Super Admin", slug: "super_admin", role_type: "admin", priority: 100
# id: 2, name: "Product Admin", slug: "product_admin", role_type: "admin", priority: 50
```

#### `rbac_permissions`
Stores all permissions.

```ruby
# Example records:
# id: 1, slug: "products:view", name: "View Products", resource_type: "products", action: "view"
# id: 2, slug: "products:create", name: "Create Products", resource_type: "products", action: "create"
```

#### `rbac_role_permissions`
Links roles to permissions (many-to-many).

```ruby
# Example records:
# role_id: 2 (product_admin), permission_id: 1 (products:view)
# role_id: 2 (product_admin), permission_id: 2 (products:create)
```

#### `admin_role_assignments`
Links admins to roles.

```ruby
# Example records:
# admin_id: 5, rbac_role_id: 2 (product_admin), is_active: true
```

#### `navigation_items`
Stores navigation menu items.

```ruby
# Example record:
# key: "products", label: "Products", required_permissions: '["products:view"]', 
# section: "Product Management", display_order: 0
```

---

## Models and Services

### Models

#### `RbacRole`
- Represents a role
- Has many permissions through `rbac_role_permissions`
- Has many admins through `admin_role_assignments`

```ruby
role = RbacRole.find_by(slug: 'product_admin')
role.rbac_permissions.pluck(:slug)
# => ["products:view", "products:create", "products:update", "categories:view"]
```

#### `RbacPermission`
- Represents a permission
- Belongs to many roles through `rbac_role_permissions`

```ruby
permission = RbacPermission.find_by(slug: 'products:view')
permission.rbac_roles.pluck(:slug)
# => ["super_admin", "product_admin", "category_manager"]
```

#### `NavigationItem`
- Represents a menu item
- Checks permissions to determine visibility

```ruby
item = NavigationItem.find_by(key: 'products')
item.can_view_item?(admin)
# => true if admin has products:view permission
```

### Services

#### `Rbac::RoleService`
Manages role assignments.

```ruby
# Assign role to admin
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'product_admin',
  assigned_by: current_admin
)

# Check if admin has role
Rbac::RoleService.admin_has_role?(admin, 'product_admin')
# => true
```

#### `Rbac::PermissionService`
Checks permissions.

```ruby
# Check if admin has permission
Rbac::PermissionService.admin_has_permission?(admin, 'products:create')
# => true

# Get all permissions for admin
Rbac::PermissionService.admin_permissions(admin)
# => ["products:view", "products:create", "products:update", ...]
```

#### `NavigationService`
Manages navigation items.

```ruby
# Get visible navigation items for admin
NavigationService.visible_items(admin)
# => { "Product Management" => [{ key: :products, label: "Products", ... }] }

# Check if admin can view specific item
NavigationService.can_view?(admin, 'products')
# => true
```

---

## Navigation Items System

### How Navigation Items Work

1. **Stored in Database**: All navigation items are stored in the `navigation_items` table
2. **Permission-Based Visibility**: Each item has `required_permissions` that determine if it's visible
3. **Dynamic Filtering**: `NavigationService` filters items based on user permissions
4. **Action Permissions**: Items can have separate permissions for view, create, edit, delete

### Navigation Item Structure

```ruby
NavigationItem.create!(
  key: 'products',
  label: 'Products',
  icon: 'fas fa-box',
  path_method: 'admin_products_path',
  section: 'Product Management',
  required_permissions: ['products:view', 'products:read'].to_json,
  view_permissions: ['products:view'].to_json,
  create_permissions: ['products:create'].to_json,
  edit_permissions: ['products:update', 'products:edit'].to_json,
  delete_permissions: ['products:delete', 'products:destroy'].to_json,
  can_view: true,
  can_create: true,
  can_edit: true,
  can_delete: true,
  display_order: 0,
  is_system: true
)
```

### Permission Checking Logic

When checking if a user can view a navigation item:

1. If `always_visible: true` → Always show
2. If `require_super_admin: true` → Only show to super admins
3. Check if user has ANY of the `required_permissions`
4. If user has permission → Show item

### Seeding Navigation Items

Navigation items are seeded via:
- **Migration**: `db/migrate/20250118000002_seed_navigation_items.rb`
- **Rake Task**: `rails navigation_items:seed`
- **Seed File**: Automatically seeded when running `rails db:seed`
- **Shared Module**: `lib/navigation_items_seeder.rb`

All 16 system navigation items are defined in `lib/navigation_items_seeder.rb`.

---

## Usage Examples

### Example 1: Assign Role to Admin

```ruby
# Find admin
admin = Admin.find_by(email: 'john@example.com')

# Assign product_admin role
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'product_admin',
  assigned_by: current_admin
)

# Now admin has all permissions from product_admin role
admin.has_permission?('products:view')
# => true

admin.has_permission?('products:create')
# => true
```

### Example 2: Check Permissions in Controller

```ruby
class Admin::ProductsController < ApplicationController
  include AdminAuthorization
  
  before_action :require_permission!, only: [:create], with: 'products:create'
  before_action :require_permission!, only: [:update], with: 'products:update'
  before_action :require_permission!, only: [:destroy], with: 'products:delete'
  
  def index
    # Only shown if user has products:view permission
    @products = Product.all
  end
  
  def create
    # Only accessible if user has products:create permission
    @product = Product.new(product_params)
    # ...
  end
end
```

### Example 3: Check Navigation Item Visibility

```ruby
# In a view or helper
<% if NavigationService.can_view?(current_admin, 'products') %>
  <%= link_to 'Products', admin_products_path %>
<% end %>

# Or get all visible items
<% visible_items = NavigationService.visible_items(current_admin) %>
<% visible_items.each do |section, items| %>
  <h3><%= section %></h3>
  <% items.each do |item| %>
    <%= link_to item[:label], send(item[:path]) %>
  <% end %>
<% end %>
```

### Example 4: Get All Permissions for Admin

```ruby
admin = Admin.find_by(email: 'john@example.com')

# Get all permissions
permissions = Rbac::PermissionService.admin_permissions(admin)
# => ["products:view", "products:create", "products:update", "categories:view", ...]

# Check specific permission
Rbac::PermissionService.admin_has_permission?(admin, 'products:create')
# => true

# Check multiple permissions (any)
Rbac::PermissionService.admin_has_any_permission?(admin, ['products:create', 'products:update'])
# => true

# Check multiple permissions (all)
Rbac::PermissionService.admin_has_all_permissions?(admin, ['products:create', 'products:update'])
# => true
```

---

## Common Workflows

### Workflow 1: Creating a New Admin with Role

```ruby
# 1. Create admin
admin = Admin.create!(
  email: 'newadmin@example.com',
  password: 'password123',
  first_name: 'John',
  last_name: 'Doe'
)

# 2. Assign role
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'product_admin',
  assigned_by: current_admin
)

# 3. Admin now has permissions and can see navigation items
admin.has_permission?('products:view')
# => true

NavigationService.can_view?(admin, 'products')
# => true
```

### Workflow 2: Changing Admin's Role

```ruby
admin = Admin.find_by(email: 'john@example.com')

# Remove old role
Rbac::RoleService.remove_role_from_admin(
  admin: admin,
  role_slug: 'product_admin'
)

# Assign new role
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'order_manager',
  assigned_by: current_admin
)

# Permissions and navigation items update automatically
```

### Workflow 3: Adding Custom Permission to Role

```ruby
# Find role
role = RbacRole.find_by(slug: 'product_admin')

# Find or create permission
permission = RbacPermission.find_or_create_by(slug: 'reports:view') do |p|
  p.name = 'View Reports'
  p.resource_type = 'reports'
  p.action = 'view'
  p.category = 'Reports'
end

# Add permission to role
RbacRolePermission.find_or_create_by(
  rbac_role: role,
  rbac_permission: permission
)

# All admins with this role now have the new permission
```

### Workflow 4: Creating Custom Navigation Item

```ruby
# Create navigation item
NavigationItem.create!(
  key: 'custom_reports',
  label: 'Custom Reports',
  icon: 'fas fa-chart-line',
  path_method: 'admin_custom_reports_path',
  section: 'Reports',
  required_permissions: ['reports:view'].to_json,
  can_view: true,
  display_order: 10,
  is_system: false, # Custom item, can be deleted
  controller_name: 'custom_reports'
)

# Item will be visible to admins with reports:view permission
```

---

## Adding New Roles, Permissions, or Navigation Items

### Adding a New Role

1. **Create role in database:**
```ruby
RbacRole.create!(
  name: 'Content Manager',
  slug: 'content_manager',
  role_type: 'admin',
  priority: 40,
  description: 'Manages content and pages',
  is_system: false
)
```

2. **Assign permissions to role:**
```ruby
role = RbacRole.find_by(slug: 'content_manager')
permissions = ['pages:view', 'pages:create', 'pages:update', 'pages:delete']

permissions.each do |perm_slug|
  permission = RbacPermission.find_by(slug: perm_slug)
  RbacRolePermission.find_or_create_by(
    rbac_role: role,
    rbac_permission: permission
  )
end
```

3. **Assign role to admin:**
```ruby
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'content_manager',
  assigned_by: current_admin
)
```

### Adding a New Permission

1. **Create permission:**
```ruby
RbacPermission.create!(
  slug: 'pages:view',
  name: 'View Pages',
  resource_type: 'pages',
  action: 'view',
  category: 'Content Management',
  description: 'Can view content pages'
)
```

2. **Add to role(s):**
```ruby
role = RbacRole.find_by(slug: 'content_manager')
permission = RbacPermission.find_by(slug: 'pages:view')

RbacRolePermission.find_or_create_by(
  rbac_role: role,
  rbac_permission: permission
)
```

3. **Use in controller:**
```ruby
before_action :require_permission!, only: [:index], with: 'pages:view'
```

### Adding a New Navigation Item

1. **Create navigation item:**
```ruby
NavigationItem.create!(
  key: 'pages',
  label: 'Pages',
  icon: 'fas fa-file-alt',
  path_method: 'admin_pages_path',
  section: 'Content Management',
  required_permissions: ['pages:view'].to_json,
  view_permissions: ['pages:view'].to_json,
  create_permissions: ['pages:create'].to_json,
  edit_permissions: ['pages:update'].to_json,
  delete_permissions: ['pages:delete'].to_json,
  can_view: true,
  can_create: true,
  can_edit: true,
  can_delete: true,
  display_order: 0,
  is_system: false,
  controller_name: 'pages',
  description: 'Manage content pages'
)
```

2. **Or add to seeder for system items:**
Add to `lib/navigation_items_seeder.rb` and run `rails navigation_items:seed`

---

## Key Concepts Summary

### Roles
- **Purpose**: Group permissions together
- **Example**: `product_admin` role has `products:view`, `products:create`, etc.
- **Assignment**: Admins can have multiple roles
- **Primary Role**: Highest priority role is considered primary

### Permissions
- **Purpose**: Define specific actions users can perform
- **Format**: `resource:action` (e.g., `products:create`)
- **Checking**: Use `admin.has_permission?('products:create')`
- **Caching**: Permissions are cached for performance

### Navigation Items
- **Purpose**: Control what menu items users see
- **Visibility**: Based on `required_permissions`
- **Dynamic**: Automatically filtered based on user permissions
- **Actions**: Can have separate permissions for view/create/edit/delete

### The Flow
1. **Admin has roles** → Roles provide permissions
2. **Permissions checked** → Navigation items check if user has required permissions
3. **Menu shown/hidden** → Items visible only if user has permissions
4. **Controller actions** → Protected by `require_permission!` checks

---

## Quick Reference

### Rake Tasks

```bash
# Seed navigation items
rails navigation_items:seed

# Reset navigation items
rails navigation_items:reset

# Assign RBAC roles to all admins
rails rbac:assign_all_roles

# Verify RBAC setup
rails rbac:verify

# Clear permission cache
rails rbac:clear_cache
```

### Common Methods

```ruby
# Check permission
admin.has_permission?('products:create')

# Get all permissions
admin.permissions

# Check role
admin.has_role?('product_admin')

# Get primary role
admin.primary_role

# Check navigation visibility
NavigationService.can_view?(admin, 'products')

# Get visible navigation items
NavigationService.visible_items(admin)
```

---

## Additional Resources

- **Models**: `app/models/rbac_role.rb`, `app/models/rbac_permission.rb`, `app/models/navigation_item.rb`
- **Services**: `app/services/rbac/role_service.rb`, `app/services/rbac/permission_service.rb`, `app/services/navigation_service.rb`
- **Concerns**: `app/models/concerns/rbac_authorizable.rb`
- **Seeders**: `lib/navigation_items_seeder.rb`
- **Migrations**: `db/migrate/*_rbac*.rb`, `db/migrate/*_navigation_items*.rb`

---

## Questions?

If you need to:
- **Understand a specific permission**: Check `rbac_permissions` table
- **See what permissions a role has**: Check `rbac_role_permissions` join table
- **See what roles an admin has**: Check `admin_role_assignments` table
- **See what navigation items exist**: Check `navigation_items` table
- **Debug permission issues**: Use `rails rbac:verify` and check cache with `rails rbac:clear_cache`
