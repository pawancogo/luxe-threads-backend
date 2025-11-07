# frozen_string_literal: true

# Concern for models that can be authorized using RBAC
module RbacAuthorizable
  extend ActiveSupport::Concern
  
  # Check if has permission (uses RBAC if available, falls back to legacy)
  def has_permission?(permission_slug)
    # Try RBAC first
    if self.is_a?(Admin)
      return true if super_admin? # Backward compatibility
      Rbac::PermissionService.admin_has_permission?(self, permission_slug)
    elsif self.is_a?(SupplierAccountUser)
      Rbac::PermissionService.supplier_user_has_permission?(self, permission_slug)
    else
      false
    end
  rescue => e
    Rails.logger.warn "RBAC permission check failed: #{e.message}, falling back to legacy"
    # Fallback to legacy methods
    legacy_has_permission?(permission_slug)
  end
  
  # Get all permissions
  def permissions
    if self.is_a?(Admin)
      return RbacPermission.all.pluck(:slug) if super_admin? # Backward compatibility
      Rbac::PermissionService.admin_permissions(self)
    elsif self.is_a?(SupplierAccountUser)
      Rbac::PermissionService.supplier_user_permissions(self)
    else
      []
    end
  rescue => e
    Rails.logger.warn "RBAC permissions fetch failed: #{e.message}, falling back to legacy"
    legacy_permissions
  end
  
  # Check if has role
  def has_role?(role_slug)
    if self.is_a?(Admin)
      Rbac::RoleService.admin_has_role?(self, role_slug)
    elsif self.is_a?(SupplierAccountUser)
      Rbac::RoleService.supplier_user_has_role?(self, role_slug)
    else
      false
    end
  rescue => e
    Rails.logger.warn "RBAC role check failed: #{e.message}, falling back to legacy"
    legacy_has_role?(role_slug)
  end
  
  # Get primary role
  def primary_role
    if self.is_a?(Admin)
      Rbac::RoleService.admin_primary_role(self) || legacy_role
    elsif self.is_a?(SupplierAccountUser)
      Rbac::RoleService.supplier_user_role(self) || legacy_role
    else
      nil
    end
  rescue => e
    Rails.logger.warn "RBAC primary role fetch failed: #{e.message}, falling back to legacy"
    legacy_role
  end
  
  private
  
  def legacy_has_permission?(permission_slug)
    # Legacy permission checking logic
    if self.is_a?(Admin)
      return true if super_admin?
      # Map common permissions to legacy methods
      case permission_slug
      when 'products:manage', 'products:create', 'products:update', 'products:delete'
        can_manage_products?
      when 'orders:manage', 'orders:update', 'orders:cancel'
        can_manage_orders?
      when 'users:manage', 'users:create', 'users:update', 'users:delete'
        can_manage_users?
      when 'suppliers:manage', 'suppliers:approve', 'suppliers:suspend'
        can_manage_suppliers?
      else
        # Try JSON permissions
        has_permission_from_json?(permission_slug)
      end
    elsif self.is_a?(SupplierAccountUser)
      # Legacy supplier permission checking
      case permission_slug
      when 'products:manage', 'products:create', 'products:update', 'products:delete'
        can_manage_products?
      when 'orders:manage', 'orders:update'
        can_manage_orders?
      when 'supplier_financials:view'
        can_view_financials?
      when 'supplier_team:manage'
        can_manage_users?
      when 'supplier_settings:manage'
        can_manage_settings?
      when 'supplier_analytics:view'
        can_view_analytics?
      else
        false
      end
    else
      false
    end
  end
  
  def legacy_permissions
    if self.is_a?(Admin)
      perms = []
      perms << 'products:manage' if can_manage_products?
      perms << 'orders:manage' if can_manage_orders?
      perms << 'users:manage' if can_manage_users?
      perms << 'suppliers:manage' if can_manage_suppliers?
      # Add JSON permissions
      perms += permissions_hash.keys if respond_to?(:permissions_hash)
      perms
    elsif self.is_a?(SupplierAccountUser)
      perms = []
      perms << 'products:manage' if can_manage_products?
      perms << 'orders:manage' if can_manage_orders?
      perms << 'supplier_financials:view' if can_view_financials?
      perms << 'supplier_team:manage' if can_manage_users?
      perms << 'supplier_settings:manage' if can_manage_settings?
      perms << 'supplier_analytics:view' if can_view_analytics?
      perms
    else
      []
    end
  end
  
  def legacy_has_role?(role_slug)
    if self.is_a?(Admin)
      role.to_s == role_slug.to_s.gsub('_admin', '')
    elsif self.is_a?(SupplierAccountUser)
      role.to_s == role_slug.to_s.gsub('supplier_', '')
    else
      false
    end
  end
  
  def legacy_role
    if self.is_a?(Admin)
      role
    elsif self.is_a?(SupplierAccountUser)
      role
    else
      nil
    end
  end
  
  def has_permission_from_json?(permission_slug)
    return false unless respond_to?(:permissions_hash)
    perms = permissions_hash
    perms[permission_slug.to_s] == true
  end
end

