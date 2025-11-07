# frozen_string_literal: true

module Rbac
  # Service for checking permissions
  class PermissionService
    class << self
      # Check if admin has permission (with caching)
      def admin_has_permission?(admin, permission_slug)
        return true if admin.super_admin? # Backward compatibility
        
        # Check cache first
        cached = PermissionCacheService.get_admin_permission(admin.id, permission_slug)
        return cached unless cached.nil?
        
        # Check RBAC roles
        has_permission = false
        
        admin.admin_role_assignments.current.includes(rbac_role: :rbac_permissions).each do |assignment|
          role = assignment.rbac_role
          
          # Check role permissions
          if role.rbac_permissions.active.exists?(slug: permission_slug)
            has_permission = true
            break
          end
          
          # Check custom permissions
          if assignment.has_custom_permission?(permission_slug)
            has_permission = true
            break
          end
        end
        
        # Cache result
        PermissionCacheService.set_admin_permission(admin.id, permission_slug, has_permission)
        
        has_permission
      end
      
      # Check if admin has any of the given permissions
      def admin_has_any_permission?(admin, permission_slugs)
        permission_slugs.any? { |slug| admin_has_permission?(admin, slug) }
      end
      
      # Check if admin has all of the given permissions
      def admin_has_all_permissions?(admin, permission_slugs)
        permission_slugs.all? { |slug| admin_has_permission?(admin, slug) }
      end
      
      # Get all permissions for an admin
      def admin_permissions(admin)
        return RbacPermission.all.pluck(:slug) if admin.super_admin? # Backward compatibility
        
        # Check cache
        cached = PermissionCacheService.get_admin_all_permissions(admin.id)
        return cached if cached
        
        permissions = Set.new
        
        admin.admin_role_assignments.current.includes(rbac_role: :rbac_permissions).each do |assignment|
          role = assignment.rbac_role
          
          # Add role permissions
          role.rbac_permissions.active.each do |perm|
            permissions.add(perm.slug)
          end
          
          # Add custom permissions
          assignment.custom_permissions_hash.each do |slug, granted|
            if granted == true
              permissions.add(slug)
            else
              permissions.delete(slug) # Remove if explicitly denied
            end
          end
        end
        
        permission_array = permissions.to_a
        
        # Cache result
        PermissionCacheService.set_admin_all_permissions(admin.id, permission_array)
        
        permission_array
      end
      
      # Check if supplier account user has permission
      def supplier_user_has_permission?(supplier_account_user, permission_slug)
        return false unless supplier_account_user.active?
        return false unless supplier_account_user.rbac_role
        
        role = supplier_account_user.rbac_role
        
        # Check role permissions
        return true if role.rbac_permissions.active.exists?(slug: permission_slug)
        
        # Check custom permissions
        supplier_account_user.has_custom_permission?(permission_slug)
      end
      
      # Get all permissions for a supplier account user
      def supplier_user_permissions(supplier_account_user)
        return [] unless supplier_account_user.active?
        return [] unless supplier_account_user.rbac_role
        
        permissions = Set.new
        
        role = supplier_account_user.rbac_role
        role.rbac_permissions.active.each do |perm|
          permissions.add(perm.slug)
        end
        
        # Add custom permissions
        supplier_account_user.custom_permissions_hash.each do |slug, granted|
          if granted == true
            permissions.add(slug)
          else
            permissions.delete(slug)
          end
        end
        
        permissions.to_a
      end
      
      # Check permission for a resource (with scope)
      def can_access_resource?(user_or_admin, resource_type, resource_id, action = 'view')
        permission_slug = "#{resource_type}:#{action}"
        
        case user_or_admin
        when Admin
          admin_has_permission?(user_or_admin, permission_slug)
        when SupplierAccountUser
          supplier_user_has_permission?(user_or_admin, permission_slug)
        else
          false
        end
      end
    end
  end
end

