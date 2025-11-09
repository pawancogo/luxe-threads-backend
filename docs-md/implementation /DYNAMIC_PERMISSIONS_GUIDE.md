# Dynamic Permissions Management Guide

## Overview

The admin panel now uses a **fully dynamic permission system** based on RBAC (Role-Based Access Control). This means you can grant or revoke access to navigation items and features **without changing any code** - everything is managed through the database.

## How It Works

### 1. Navigation Items are Mapped to Permissions

Each navigation item in the admin panel is mapped to one or more permission slugs in `NavigationService`. For example:

- **Products** requires: `products:view`, `products:read`
- **Orders** requires: `orders:view`, `orders:read`
- **Customers** requires: `users:view`, `customers:view`, `users:read`

### 2. Permissions are Stored in Database

All permissions are stored in the `rbac_permissions` table:
- `slug`: The permission identifier (e.g., `orders:view`)
- `resource_type`: The resource (e.g., `orders`, `products`)
- `action`: The action (e.g., `view`, `create`, `update`, `delete`)

### 3. Roles Have Permissions

Roles in `rbac_roles` are linked to permissions via `rbac_role_permissions`:
- A role can have multiple permissions
- An admin can have multiple roles
- Custom permissions can override role permissions

## Granting/Revoking Access

### Method 1: Assign/Remove Roles (Recommended)

**Grant access by assigning a role:**

```ruby
# In Rails console or via admin interface
admin = Admin.find_by(email: 'product_manager@example.com')
role = RbacRole.find_by(slug: 'product_admin')

# Assign role
Rbac::RoleService.assign_role_to_admin(
  admin: admin,
  role_slug: 'product_admin',
  assigned_by: current_admin
)
```

**Revoke access by removing a role:**

```ruby
# Remove role
Rbac::RoleService.remove_role_from_admin(
  admin: admin,
  role_slug: 'product_admin'
)
```

### Method 2: Add/Remove Permissions from a Role

**Grant access by adding permission to role:**

```ruby
# Find the role
role = RbacRole.find_by(slug: 'product_admin')

# Find or create the permission
permission = RbacPermission.find_or_create_by(slug: 'orders:view') do |p|
  p.name = 'View Orders'
  p.resource_type = 'orders'
  p.action = 'view'
  p.category = 'orders'
  p.is_system = false
end

# Add permission to role
role.rbac_permissions << permission unless role.rbac_permissions.include?(permission)
```

**Revoke access by removing permission from role:**

```ruby
# Remove permission from role
role.rbac_permissions.delete(permission)
```

### Method 3: Custom Permissions for Specific Admin

**Grant custom permission to a specific admin:**

```ruby
# Find admin and role assignment
admin = Admin.find_by(email: 'product_manager@example.com')
assignment = admin.admin_role_assignments.first

# Add custom permission
custom_perms = assignment.custom_permissions_hash
custom_perms['orders:view'] = true
assignment.update(custom_permissions: custom_perms)

# Clear cache
Rbac::PermissionCacheService.clear_admin_cache(admin.id)
```

**Revoke custom permission:**

```ruby
# Remove custom permission
custom_perms = assignment.custom_permissions_hash
custom_perms.delete('orders:view')
assignment.update(custom_permissions: custom_perms)

# Clear cache
Rbac::PermissionCacheService.clear_admin_cache(admin.id)
```

## Common Scenarios

### Scenario 1: Allow Product Manager to View Orders

```ruby
# Option A: Add orders:view permission to product_admin role
role = RbacRole.find_by(slug: 'product_admin')
permission = RbacPermission.find_or_create_by(slug: 'orders:view') do |p|
  p.name = 'View Orders'
  p.resource_type = 'orders'
  p.action = 'view'
  p.category = 'orders'
end
role.rbac_permissions << permission unless role.rbac_permissions.include?(permission)

# Option B: Grant custom permission to specific admin
admin = Admin.find_by(email: 'product_manager@example.com')
assignment = admin.admin_role_assignments.where(rbac_role: role).first
if assignment
  custom_perms = assignment.custom_permissions_hash
  custom_perms['orders:view'] = true
  assignment.update(custom_permissions: custom_perms)
  Rbac::PermissionCacheService.clear_admin_cache(admin.id)
end
```

### Scenario 2: Revoke Order Access from Product Manager

```ruby
# Option A: Remove permission from role (affects all admins with that role)
role = RbacRole.find_by(slug: 'product_admin')
permission = RbacPermission.find_by(slug: 'orders:view')
role.rbac_permissions.delete(permission) if permission

# Option B: Remove custom permission from specific admin
admin = Admin.find_by(email: 'product_manager@example.com')
assignment = admin.admin_role_assignments.where(rbac_role: role).first
if assignment
  custom_perms = assignment.custom_permissions_hash
  custom_perms.delete('orders:view')
  assignment.update(custom_permissions: custom_perms)
  Rbac::PermissionCacheService.clear_admin_cache(admin.id)
end
```

### Scenario 3: Allow Supplier to Access Orders in Admin Panel

```ruby
# Note: This assumes suppliers can log into admin panel
# You may need to update authentication logic separately

# Find supplier user (if they have admin access)
supplier_user = SupplierAccountUser.find_by(email: 'supplier@example.com')

# Assign a role that has orders:view permission
# Or create a custom role assignment
role = RbacRole.find_by(slug: 'supplier_order_manager')
if role && supplier_user
  # Update supplier_user's rbac_role_id if needed
  supplier_user.update(rbac_role: role)
end
```

## Available Permission Slugs

Common permission slugs used in navigation:

- `dashboard:view` - Dashboard access
- `users:view`, `customers:view` - Customer management
- `suppliers:view` - Supplier management
- `products:view` - Product management
- `categories:view` - Category management
- `orders:view` - Order management
- `promotions:view`, `marketing:view` - Promotions
- `coupons:view`, `marketing:view` - Coupons
- `reports:view`, `analytics:view` - Reports
- `audit_logs:view` - Activity history (super admin only)
- `settings:view` - Settings (super admin only)
- `email_templates:view` - Email templates (super admin only)

## Adding New Navigation Items

To add a new navigation item:

1. **Add permission to database:**
```ruby
RbacPermission.create!(
  name: 'View New Feature',
  slug: 'new_feature:view',
  resource_type: 'new_feature',
  action: 'view',
  category: 'features',
  is_system: false
)
```

2. **Update NavigationService:**
```ruby
# In app/services/navigation_service.rb
new_feature: {
  label: 'New Feature',
  icon: 'fas fa-star',
  path: :admin_new_feature_path,
  permissions: ['new_feature:view', 'new_feature:read'],
  section: 'Features'
}
```

3. **Assign permission to roles:**
```ruby
role = RbacRole.find_by(slug: 'product_admin')
permission = RbacPermission.find_by(slug: 'new_feature:view')
role.rbac_permissions << permission
```

## Caching

Permissions are cached for performance. After making changes:

```ruby
# Clear cache for specific admin
Rbac::PermissionCacheService.clear_admin_cache(admin.id)

# Clear all admin caches (use with caution)
Rbac::PermissionCacheService.clear_all_caches
```

## Testing Permissions

```ruby
# Check if admin has permission
admin = Admin.find_by(email: 'test@example.com')
admin.has_permission?('orders:view') # => true/false

# Check if can view navigation item
NavigationService.can_view?(admin, :orders) # => true/false

# Get all visible navigation items
NavigationService.visible_items(admin) # => Hash of sections and items
```

## Important Notes

1. **Super Admins** always have access to everything (bypasses all permission checks)
2. **Permission changes take effect immediately** after cache is cleared
3. **Navigation items are hidden** if user doesn't have required permissions
4. **Section headers are hidden** if no items in that section are visible
5. **Legacy role checks** (like `can_manage_products?`) still work for backward compatibility

## Troubleshooting

**Navigation item not showing:**
1. Check if admin has the required permission: `admin.has_permission?('orders:view')`
2. Check if permission exists: `RbacPermission.find_by(slug: 'orders:view')`
3. Clear cache: `Rbac::PermissionCacheService.clear_admin_cache(admin.id)`
4. Check NavigationService configuration for the item

**Permission not working:**
1. Verify permission slug matches exactly (case-sensitive)
2. Check if role assignment is active: `assignment.active?`
3. Check if role assignment has expired: `assignment.expired?`
4. Clear permission cache

**Changes not reflecting:**
1. Clear the permission cache
2. Restart the Rails server (if using file-based cache)
3. Check if admin is logged out and back in

