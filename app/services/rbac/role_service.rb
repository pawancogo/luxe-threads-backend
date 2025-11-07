# frozen_string_literal: true

module Rbac
  # Service for managing roles and role assignments
  class RoleService
    class << self
      # Assign a role to an admin
      def assign_role_to_admin(admin:, role_slug:, assigned_by: nil, expires_at: nil, custom_permissions: {})
        role = RbacRole.find_by(slug: role_slug, role_type: ['admin', 'system'])
        raise ArgumentError, "Role not found: #{role_slug}" unless role
        
        assignment = AdminRoleAssignment.find_or_initialize_by(
          admin: admin,
          rbac_role: role
        )
        
        assignment.assign_attributes(
          assigned_by: assigned_by || admin,
          assigned_at: Time.current,
          expires_at: expires_at,
          custom_permissions: custom_permissions,
          is_active: true
        )
        
        assignment.save!
        
        # Clear cache
        PermissionCacheService.clear_admin_cache(admin.id)
        
        assignment
      end
      
      # Remove a role from an admin
      def remove_role_from_admin(admin:, role_slug:)
        role = RbacRole.find_by(slug: role_slug)
        return false unless role
        
        assignment = AdminRoleAssignment.find_by(admin: admin, rbac_role: role)
        return false unless assignment
        
        assignment.update(is_active: false)
        
        # Clear cache
        PermissionCacheService.clear_admin_cache(admin.id)
        
        true
      end
      
      # Assign a role to a supplier account user
      def assign_role_to_supplier_user(supplier_account_user:, role_slug:, assigned_by: nil)
        role = RbacRole.find_by(slug: role_slug, role_type: ['supplier', 'system'])
        raise ArgumentError, "Role not found: #{role_slug}" unless role
        
        supplier_account_user.update!(
          rbac_role: role,
          role_assigned_at: Time.current,
          role_assigned_by: assigned_by
        )
        
        # Clear cache
        PermissionCacheService.clear_supplier_user_cache(supplier_account_user.id)
        
        supplier_account_user
      end
      
      # Get all roles for an admin
      def admin_roles(admin)
        admin.admin_role_assignments.current.includes(:rbac_role).map(&:rbac_role)
      end
      
      # Get primary role for an admin (highest priority)
      def admin_primary_role(admin)
        admin.admin_role_assignments.current
          .joins(:rbac_role)
          .order('rbac_roles.priority DESC')
          .first&.rbac_role
      end
      
      # Check if admin has a specific role
      def admin_has_role?(admin, role_slug)
        admin.admin_role_assignments.current
          .joins(:rbac_role)
          .exists?(rbac_roles: { slug: role_slug })
      end
      
      # Get role for supplier account user
      def supplier_user_role(supplier_account_user)
        supplier_account_user.rbac_role
      end
      
      # Check if supplier user has a specific role
      def supplier_user_has_role?(supplier_account_user, role_slug)
        supplier_account_user.rbac_role&.slug == role_slug
      end
      
      # Map legacy admin role enum to RBAC role slug
      def map_legacy_admin_role(legacy_role)
        mapping = {
          'super_admin' => 'super_admin',
          'product_admin' => 'product_admin',
          'order_admin' => 'order_manager',
          'user_admin' => 'user_admin',
          'supplier_admin' => 'supplier_admin'
        }
        mapping[legacy_role.to_s] || 'staff'
      end
      
      # Map legacy supplier role enum to RBAC role slug
      def map_legacy_supplier_role(legacy_role)
        mapping = {
          'owner' => 'supplier_owner',
          'admin' => 'supplier_manager',
          'product_manager' => 'supplier_product_manager',
          'order_manager' => 'supplier_order_manager',
          'accountant' => 'supplier_accountant',
          'staff' => 'supplier_staff'
        }
        mapping[legacy_role.to_s] || 'supplier_staff'
      end
    end
  end
end

