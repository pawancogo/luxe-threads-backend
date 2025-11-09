# RBAC Implementation Guide

## Overview

This document describes the Role-Based Access Control (RBAC) system implemented for the e-commerce platform. The system supports:

1. **Multi-Supplier Architecture**: Suppliers can only manage their own products, orders, and inventory
2. **Multi-Admin Role System**: Different admin roles with permission-based access
3. **Extensible Design**: Easy to add new roles or permissions without schema changes

## Architecture

### Database Schema

- `rbac_roles`: Defines roles (admin, supplier, system)
- `rbac_permissions`: Defines individual permissions
- `rbac_role_permissions`: Links roles to permissions
- `admin_role_assignments`: Links admins to RBAC roles
- `supplier_account_users.rbac_role_id`: Links supplier users to RBAC roles

### Service Layer

1. **Rbac::RoleService**: Manages role assignments
2. **Rbac::PermissionService**: Checks permissions
3. **Rbac::AuthorizationService**: Centralized authorization logic
4. **Rbac::PermissionCacheService**: Caching layer (Rails.cache with Redis-ready interface)

### Models

- `Admin` includes `RbacAuthorizable` concern
- `SupplierAccountUser` includes `RbacAuthorizable` concern

### Controllers

- `AdminAuthorization` concern for admin controllers
- `SupplierAuthorization` concern for supplier controllers

## Usage

### Admin Controllers

```ruby
class Api::V1::Admin::ProductsController < ApplicationController
  include AdminAuthorization
  
  before_action :require_permission!, only: [:create], with: 'products:create'
  before_action :require_permission!, only: [:update], with: 'products:update'
  before_action :require_permission!, only: [:destroy], with: 'products:delete'
  
  def index
    # Scope by permission
    products = scope_by_permission(Product.all, 'products', 'view')
    # ...
  end
end
```

### Supplier Controllers

```ruby
class Api::V1::ProductsController < ApplicationController
  include SupplierAuthorization
  
  before_action :require_supplier_permission!, only: [:create], with: 'products:create'
  
  def index
    # Automatically scoped to current supplier
    products = scope_supplier_products
    # ...
  end
  
  def show
    @product = scope_supplier_products.find(params[:id])
    # ...
  end
end
```

### Assigning Roles

```ruby
# Assign role to admin
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'category_manager',
  assigned_by: current_admin
)

# Assign role to supplier user
Rbac::RoleService.assign_role_to_supplier_user(
  supplier_account_user: supplier_user,
  role_slug: 'supplier_product_manager',
  assigned_by: owner_user
)
```

### Checking Permissions

```ruby
# In models (via RbacAuthorizable concern)
admin.has_permission?('products:manage')
supplier_user.has_permission?('products:create')

# In services
Rbac::PermissionService.admin_has_permission?(admin, 'products:create')
Rbac::AuthorizationService.authorize_admin!(admin, 'products:create', resource: product)
```

## Backward Compatibility

The system maintains backward compatibility:

1. Legacy `admin.role` enum still works
2. Legacy `admin.has_permission?` method still works (uses RBAC with fallback)
3. Legacy `supplier_account_user.role` enum still works
4. Legacy permission checking methods still work

## Caching

Permissions are cached using Rails.cache (with Redis-ready interface). Cache is automatically cleared when:
- Roles are assigned/removed
- Permissions are updated

## Migration Path

1. Run migrations to create RBAC tables
2. Seed initial roles and permissions
3. Existing admins keep working (legacy role check)
4. Gradually assign RBAC roles to admins
5. Update controllers to use new authorization

## Adding New Roles

1. Create role in `rbac_roles` table
2. Assign permissions to role via `rbac_role_permissions`
3. Use in controllers/service layer

## Adding New Permissions

1. Create permission in `rbac_permissions` table
2. Assign to roles via `rbac_role_permissions`
3. Use in controllers: `require_permission!('new_permission:action')`

