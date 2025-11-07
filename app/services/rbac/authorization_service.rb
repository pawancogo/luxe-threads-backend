# frozen_string_literal: true

module Rbac
  # Centralized authorization service
  class AuthorizationService
    class << self
      # Authorize admin action
      def authorize_admin!(admin, permission_slug, resource: nil)
        unless PermissionService.admin_has_permission?(admin, permission_slug)
          raise AuthorizationError, "Admin does not have permission: #{permission_slug}"
        end
        
        # Additional resource-specific checks can be added here
        if resource && respond_to?(:"check_#{resource.class.name.underscore}_access", true)
          send(:"check_#{resource.class.name.underscore}_access", admin, resource)
        end
        
        true
      end
      
      # Authorize supplier user action
      def authorize_supplier_user!(supplier_account_user, permission_slug, resource: nil)
        unless PermissionService.supplier_user_has_permission?(supplier_account_user, permission_slug)
          raise AuthorizationError, "Supplier user does not have permission: #{permission_slug}"
        end
        
        # Check supplier scoping
        if resource && resource.respond_to?(:supplier_profile_id)
          unless resource.supplier_profile_id == supplier_account_user.supplier_profile_id
            raise AuthorizationError, "Access denied: Resource belongs to different supplier"
          end
        end
        
        true
      end
      
      # Check if admin can access supplier-scoped resource
      def admin_can_access_supplier_resource?(admin, supplier_profile_id)
        return true if admin.super_admin? # Super admin can access all
        
        # Check if admin has supplier management permissions
        PermissionService.admin_has_permission?(admin, 'suppliers:view') ||
          PermissionService.admin_has_permission?(admin, 'suppliers:manage')
      end
      
      # Scope products to supplier (for supplier users)
      def scope_products_for_supplier(supplier_account_user)
        return Product.none unless supplier_account_user.active?
        
        supplier_profile = supplier_account_user.supplier_profile
        Product.where(supplier_profile_id: supplier_profile.id)
      end
      
      # Scope orders to supplier (for supplier users)
      def scope_orders_for_supplier(supplier_account_user)
        return Order.none unless supplier_account_user.active?
        
        supplier_profile = supplier_account_user.supplier_profile
        Order.joins(order_items: :product)
          .where(products: { supplier_profile_id: supplier_profile.id })
      end
      
      # Scope analytics to supplier (for supplier users)
      def scope_analytics_for_supplier(supplier_account_user)
        return {} unless supplier_account_user.active?
        
        supplier_profile = supplier_account_user.supplier_profile
        
        {
          supplier_profile_id: supplier_profile.id,
          products: Product.where(supplier_profile_id: supplier_profile.id),
          orders: scope_orders_for_supplier(supplier_account_user)
        }
      end
      
      # Check CRUD permissions for a resource
      def can_create?(user_or_admin, resource_type)
        PermissionService.can_access_resource?(user_or_admin, resource_type, nil, 'create')
      end
      
      def can_read?(user_or_admin, resource_type)
        PermissionService.can_access_resource?(user_or_admin, resource_type, nil, 'view')
      end
      
      def can_update?(user_or_admin, resource_type)
        PermissionService.can_access_resource?(user_or_admin, resource_type, nil, 'update')
      end
      
      def can_delete?(user_or_admin, resource_type)
        PermissionService.can_access_resource?(user_or_admin, resource_type, nil, 'delete')
      end
      
      def can_manage?(user_or_admin, resource_type)
        PermissionService.can_access_resource?(user_or_admin, resource_type, nil, 'manage')
      end
    end
    
    # Custom exception for authorization errors
    class AuthorizationError < StandardError; end
  end
end

