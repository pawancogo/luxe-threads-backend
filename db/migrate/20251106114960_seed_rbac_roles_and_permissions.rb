# frozen_string_literal: true

class SeedRbacRolesAndPermissions < ActiveRecord::Migration[7.1]
  def up
    # Create Admin Roles
    admin_roles = [
      {
        name: 'Super Admin',
        slug: 'super_admin',
        role_type: 'admin',
        description: 'Full system access with all permissions',
        is_system: true,
        priority: 100
      },
      {
        name: 'Category Manager',
        slug: 'category_manager',
        role_type: 'admin',
        description: 'Manages product categories and related operations',
        is_system: true,
        priority: 60
      },
      {
        name: 'Order Manager',
        slug: 'order_manager',
        role_type: 'admin',
        description: 'Manages orders, shipments, and returns',
        is_system: true,
        priority: 60
      },
      {
        name: 'Support Admin',
        slug: 'support_admin',
        role_type: 'admin',
        description: 'Manages customer support tickets and inquiries',
        is_system: true,
        priority: 50
      },
      {
        name: 'Product Admin',
        slug: 'product_admin',
        role_type: 'admin',
        description: 'Manages products, approvals, and catalog',
        is_system: true,
        priority: 60
      },
      {
        name: 'User Admin',
        slug: 'user_admin',
        role_type: 'admin',
        description: 'Manages user accounts and customer data',
        is_system: true,
        priority: 60
      },
      {
        name: 'Supplier Admin',
        slug: 'supplier_admin',
        role_type: 'admin',
        description: 'Manages supplier accounts and verification',
        is_system: true,
        priority: 60
      }
    ]
    
    # Create Supplier Roles
    supplier_roles = [
      {
        name: 'Supplier Owner',
        slug: 'supplier_owner',
        role_type: 'supplier',
        description: 'Full access to supplier account and all operations',
        is_system: true,
        priority: 90
      },
      {
        name: 'Supplier Manager',
        slug: 'supplier_manager',
        role_type: 'supplier',
        description: 'Manages products, orders, and team members',
        is_system: true,
        priority: 70
      },
      {
        name: 'Product Manager',
        slug: 'supplier_product_manager',
        role_type: 'supplier',
        description: 'Manages products and inventory',
        is_system: true,
        priority: 50
      },
      {
        name: 'Order Manager',
        slug: 'supplier_order_manager',
        role_type: 'supplier',
        description: 'Manages orders and shipments',
        is_system: true,
        priority: 50
      },
      {
        name: 'Accountant',
        slug: 'supplier_accountant',
        role_type: 'supplier',
        description: 'Views financial data and reports',
        is_system: true,
        priority: 40
      },
      {
        name: 'Staff',
        slug: 'supplier_staff',
        role_type: 'supplier',
        description: 'Limited access for basic operations',
        is_system: true,
        priority: 30
      }
    ]
    
    # Insert roles
    all_roles = admin_roles + supplier_roles
    all_roles.each do |role_data|
      RbacRole.find_or_create_by(slug: role_data[:slug]) do |role|
        role.assign_attributes(role_data)
      end
    end
    
    # Create Permissions
    permissions = [
      # Product permissions
      { name: 'View Products', slug: 'products:view', resource_type: 'product', action: 'view', category: 'product' },
      { name: 'Create Products', slug: 'products:create', resource_type: 'product', action: 'create', category: 'product' },
      { name: 'Update Products', slug: 'products:update', resource_type: 'product', action: 'update', category: 'product' },
      { name: 'Delete Products', slug: 'products:delete', resource_type: 'product', action: 'delete', category: 'product' },
      { name: 'Approve Products', slug: 'products:approve', resource_type: 'product', action: 'approve', category: 'product' },
      { name: 'Reject Products', slug: 'products:reject', resource_type: 'product', action: 'reject', category: 'product' },
      { name: 'Manage Products', slug: 'products:manage', resource_type: 'product', action: 'manage', category: 'product' },
      
      # Order permissions
      { name: 'View Orders', slug: 'orders:view', resource_type: 'order', action: 'view', category: 'order' },
      { name: 'Create Orders', slug: 'orders:create', resource_type: 'order', action: 'create', category: 'order' },
      { name: 'Update Orders', slug: 'orders:update', resource_type: 'order', action: 'update', category: 'order' },
      { name: 'Cancel Orders', slug: 'orders:cancel', resource_type: 'order', action: 'cancel', category: 'order' },
      { name: 'Manage Orders', slug: 'orders:manage', resource_type: 'order', action: 'manage', category: 'order' },
      { name: 'Process Refunds', slug: 'orders:refund', resource_type: 'order', action: 'refund', category: 'order' },
      
      # Category permissions
      { name: 'View Categories', slug: 'categories:view', resource_type: 'category', action: 'view', category: 'product' },
      { name: 'Create Categories', slug: 'categories:create', resource_type: 'category', action: 'create', category: 'product' },
      { name: 'Update Categories', slug: 'categories:update', resource_type: 'category', action: 'update', category: 'product' },
      { name: 'Delete Categories', slug: 'categories:delete', resource_type: 'category', action: 'delete', category: 'product' },
      { name: 'Manage Categories', slug: 'categories:manage', resource_type: 'category', action: 'manage', category: 'product' },
      
      # User permissions
      { name: 'View Users', slug: 'users:view', resource_type: 'user', action: 'view', category: 'user' },
      { name: 'Create Users', slug: 'users:create', resource_type: 'user', action: 'create', category: 'user' },
      { name: 'Update Users', slug: 'users:update', resource_type: 'user', action: 'update', category: 'user' },
      { name: 'Delete Users', slug: 'users:delete', resource_type: 'user', action: 'delete', category: 'user' },
      { name: 'Manage Users', slug: 'users:manage', resource_type: 'user', action: 'manage', category: 'user' },
      
      # Supplier permissions
      { name: 'View Suppliers', slug: 'suppliers:view', resource_type: 'supplier', action: 'view', category: 'supplier' },
      { name: 'Create Suppliers', slug: 'suppliers:create', resource_type: 'supplier', action: 'create', category: 'supplier' },
      { name: 'Update Suppliers', slug: 'suppliers:update', resource_type: 'supplier', action: 'update', category: 'supplier' },
      { name: 'Delete Suppliers', slug: 'suppliers:delete', resource_type: 'supplier', action: 'delete', category: 'supplier' },
      { name: 'Approve Suppliers', slug: 'suppliers:approve', resource_type: 'supplier', action: 'approve', category: 'supplier' },
      { name: 'Suspend Suppliers', slug: 'suppliers:suspend', resource_type: 'supplier', action: 'suspend', category: 'supplier' },
      { name: 'Manage Suppliers', slug: 'suppliers:manage', resource_type: 'supplier', action: 'manage', category: 'supplier' },
      
      # Admin permissions
      { name: 'View Admins', slug: 'admins:view', resource_type: 'admin', action: 'view', category: 'admin' },
      { name: 'Create Admins', slug: 'admins:create', resource_type: 'admin', action: 'create', category: 'admin' },
      { name: 'Update Admins', slug: 'admins:update', resource_type: 'admin', action: 'update', category: 'admin' },
      { name: 'Delete Admins', slug: 'admins:delete', resource_type: 'admin', action: 'delete', category: 'admin' },
      { name: 'Manage Admins', slug: 'admins:manage', resource_type: 'admin', action: 'manage', category: 'admin' },
      { name: 'Assign Roles', slug: 'admins:assign_roles', resource_type: 'admin', action: 'assign_roles', category: 'admin' },
      
      # Reports & Analytics
      { name: 'View Reports', slug: 'reports:view', resource_type: 'report', action: 'view', category: 'report' },
      { name: 'Export Reports', slug: 'reports:export', resource_type: 'report', action: 'export', category: 'report' },
      
      # Settings
      { name: 'View Settings', slug: 'settings:view', resource_type: 'setting', action: 'view', category: 'system' },
      { name: 'Update Settings', slug: 'settings:update', resource_type: 'setting', action: 'update', category: 'system' },
      { name: 'Manage Settings', slug: 'settings:manage', resource_type: 'setting', action: 'manage', category: 'system' },
      
      # Supplier-specific permissions
      { name: 'View Supplier Analytics', slug: 'supplier_analytics:view', resource_type: 'supplier_analytics', action: 'view', category: 'supplier' },
      { name: 'View Supplier Financials', slug: 'supplier_financials:view', resource_type: 'supplier_financials', action: 'view', category: 'supplier' },
      { name: 'Manage Supplier Team', slug: 'supplier_team:manage', resource_type: 'supplier_team', action: 'manage', category: 'supplier' },
      { name: 'Manage Supplier Settings', slug: 'supplier_settings:manage', resource_type: 'supplier_settings', action: 'manage', category: 'supplier' }
    ]
    
    # Insert permissions
    permissions.each do |perm_data|
      RbacPermission.find_or_create_by(slug: perm_data[:slug]) do |perm|
        perm.assign_attributes(perm_data.merge(is_system: true))
      end
    end
    
    # Assign permissions to roles
    assign_permissions_to_roles
  end
  
  def down
    RbacRolePermission.delete_all
    RbacPermission.delete_all
    RbacRole.delete_all
  end
  
  private
  
  def assign_permissions_to_roles
    # Super Admin gets all permissions
    super_admin_role = RbacRole.find_by(slug: 'super_admin')
    super_admin_role&.rbac_permissions << RbacPermission.all
    
    # Category Manager permissions
    category_manager = RbacRole.find_by(slug: 'category_manager')
    if category_manager
      perms = RbacPermission.where(slug: [
        'categories:view', 'categories:create', 'categories:update', 'categories:delete', 'categories:manage',
        'products:view', 'products:approve', 'products:reject'
      ])
      category_manager.rbac_permissions = perms
    end
    
    # Order Manager permissions
    order_manager = RbacRole.find_by(slug: 'order_manager')
    if order_manager
      perms = RbacPermission.where(slug: [
        'orders:view', 'orders:update', 'orders:manage', 'orders:refund',
        'reports:view', 'reports:export'
      ])
      order_manager.rbac_permissions = perms
    end
    
    # Support Admin permissions
    support_admin = RbacRole.find_by(slug: 'support_admin')
    if support_admin
      perms = RbacPermission.where(slug: [
        'users:view', 'users:update',
        'orders:view', 'orders:update',
        'reports:view'
      ])
      support_admin.rbac_permissions = perms
    end
    
    # Product Admin permissions
    product_admin = RbacRole.find_by(slug: 'product_admin')
    if product_admin
      perms = RbacPermission.where(slug: [
        'products:view', 'products:create', 'products:update', 'products:delete', 'products:approve', 'products:reject', 'products:manage',
        'categories:view', 'categories:create', 'categories:update', 'categories:delete', 'categories:manage'
      ])
      product_admin.rbac_permissions = perms
    end
    
    # User Admin permissions
    user_admin = RbacRole.find_by(slug: 'user_admin')
    if user_admin
      perms = RbacPermission.where(slug: [
        'users:view', 'users:create', 'users:update', 'users:delete', 'users:manage',
        'reports:view', 'reports:export'
      ])
      user_admin.rbac_permissions = perms
    end
    
    # Supplier Admin permissions
    supplier_admin = RbacRole.find_by(slug: 'supplier_admin')
    if supplier_admin
      perms = RbacPermission.where(slug: [
        'suppliers:view', 'suppliers:create', 'suppliers:update', 'suppliers:approve', 'suppliers:suspend', 'suppliers:manage',
        'reports:view', 'reports:export'
      ])
      supplier_admin.rbac_permissions = perms
    end
    
    # Supplier Owner permissions (full access to supplier operations)
    supplier_owner = RbacRole.find_by(slug: 'supplier_owner')
    if supplier_owner
      perms = RbacPermission.where(slug: [
        'products:view', 'products:create', 'products:update', 'products:delete', 'products:manage',
        'orders:view', 'orders:update', 'orders:manage',
        'supplier_analytics:view', 'supplier_financials:view',
        'supplier_team:manage', 'supplier_settings:manage'
      ])
      supplier_owner.rbac_permissions = perms
    end
    
    # Supplier Manager permissions
    supplier_manager = RbacRole.find_by(slug: 'supplier_manager')
    if supplier_manager
      perms = RbacPermission.where(slug: [
        'products:view', 'products:create', 'products:update', 'products:manage',
        'orders:view', 'orders:update', 'orders:manage',
        'supplier_analytics:view',
        'supplier_team:manage'
      ])
      supplier_manager.rbac_permissions = perms
    end
    
    # Supplier Product Manager permissions
    supplier_product_manager = RbacRole.find_by(slug: 'supplier_product_manager')
    if supplier_product_manager
      perms = RbacPermission.where(slug: [
        'products:view', 'products:create', 'products:update', 'products:delete', 'products:manage',
        'supplier_analytics:view'
      ])
      supplier_product_manager.rbac_permissions = perms
    end
    
    # Supplier Order Manager permissions
    supplier_order_manager = RbacRole.find_by(slug: 'supplier_order_manager')
    if supplier_order_manager
      perms = RbacPermission.where(slug: [
        'orders:view', 'orders:update', 'orders:manage',
        'supplier_analytics:view'
      ])
      supplier_order_manager.rbac_permissions = perms
    end
    
    # Supplier Accountant permissions
    supplier_accountant = RbacRole.find_by(slug: 'supplier_accountant')
    if supplier_accountant
      perms = RbacPermission.where(slug: [
        'supplier_financials:view',
        'reports:view', 'reports:export'
      ])
      supplier_accountant.rbac_permissions = perms
    end
    
    # Supplier Staff permissions (very limited)
    supplier_staff = RbacRole.find_by(slug: 'supplier_staff')
    if supplier_staff
      perms = RbacPermission.where(slug: [
        'products:view',
        'orders:view'
      ])
      supplier_staff.rbac_permissions = perms
    end
  end
end

