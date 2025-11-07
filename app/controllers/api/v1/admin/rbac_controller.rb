# frozen_string_literal: true

module Api::V1::Admin
  class RbacController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin!, only: [:assign_role, :remove_role, :update_permissions]
    before_action :set_target_admin, only: [:assign_role, :remove_role, :update_permissions, :roles]
    
    # GET /api/v1/admin/rbac/roles
    # Get all available roles
    def roles
      role_type = params[:role_type] || 'admin'
      roles = RbacRole.where(role_type: [role_type, 'system']).active
      
      render_success(
        roles.map { |role| format_role(role) },
        'Roles retrieved successfully'
      )
    end
    
    # GET /api/v1/admin/rbac/permissions
    # Get all permissions
    def permissions
      category = params[:category]
      permissions = RbacPermission.active
      permissions = permissions.where(category: category) if category.present?
      
      render_success(
        permissions.map { |perm| format_permission(perm) },
        'Permissions retrieved successfully'
      )
    end
    
    # GET /api/v1/admin/rbac/admins/:id/roles
    # Get roles assigned to an admin
    def admin_roles
      admin = Admin.find(params[:id])
      assignments = admin.admin_role_assignments.current.includes(:rbac_role)
      
      render_success(
        assignments.map { |assignment| format_assignment(assignment) },
        'Admin roles retrieved successfully'
      )
    end
    
    # POST /api/v1/admin/rbac/admins/:id/assign_role
    # Assign a role to an admin
    def assign_role
      role_slug = params[:role_slug]
      expires_at = params[:expires_at] ? Time.parse(params[:expires_at]) : nil
      custom_permissions = params[:custom_permissions] || {}
      
      assignment = Rbac::RoleService.assign_role_to_admin(
        admin: @target_admin,
        role_slug: role_slug,
        assigned_by: @current_admin,
        expires_at: expires_at,
        custom_permissions: custom_permissions
      )
      
      log_admin_activity('assign_role', 'Admin', @target_admin.id, {
        role_slug: role_slug,
        expires_at: expires_at
      })
      
      render_success(
        format_assignment(assignment),
        'Role assigned successfully'
      )
    rescue ArgumentError => e
      render_validation_errors([e.message], 'Role assignment failed')
    end
    
    # DELETE /api/v1/admin/rbac/admins/:id/remove_role/:role_slug
    # Remove a role from an admin
    def remove_role
      role_slug = params[:role_slug]
      
      success = Rbac::RoleService.remove_role_from_admin(
        admin: @target_admin,
        role_slug: role_slug
      )
      
      if success
        log_admin_activity('remove_role', 'Admin', @target_admin.id, {
          role_slug: role_slug
        })
        
        render_success({}, 'Role removed successfully')
      else
        render_validation_errors(['Role not found or not assigned'], 'Role removal failed')
      end
    end
    
    # PATCH /api/v1/admin/rbac/admins/:id/update_permissions
    # Update custom permissions for an admin role assignment
    def update_permissions
      role_slug = params[:role_slug]
      custom_permissions = params[:custom_permissions] || {}
      
      assignment = AdminRoleAssignment.joins(:rbac_role)
        .find_by(admin: @target_admin, rbac_roles: { slug: role_slug })
      
      unless assignment
        render_not_found('Role assignment not found')
        return
      end
      
      assignment.update!(custom_permissions: custom_permissions)
      
      # Clear cache
      Rbac::PermissionCacheService.clear_admin_cache(@target_admin.id)
      
      log_admin_activity('update_permissions', 'Admin', @target_admin.id, {
        role_slug: role_slug,
        custom_permissions: custom_permissions
      })
      
      render_success(
        format_assignment(assignment),
        'Permissions updated successfully'
      )
    end
    
    private
    
    def set_target_admin
      @target_admin = Admin.find(params[:id])
    end
    
    def format_role(role)
      {
        id: role.id,
        name: role.name,
        slug: role.slug,
        role_type: role.role_type,
        description: role.description,
        priority: role.priority,
        permissions: role.rbac_permissions.active.pluck(:slug)
      }
    end
    
    def format_permission(permission)
      {
        id: permission.id,
        name: permission.name,
        slug: permission.slug,
        resource_type: permission.resource_type,
        action: permission.action,
        category: permission.category,
        full_permission: permission.full_permission
      }
    end
    
    def format_assignment(assignment)
      {
        id: assignment.id,
        admin_id: assignment.admin_id,
        role: format_role(assignment.rbac_role),
        assigned_by: assignment.assigned_by&.full_name,
        assigned_at: assignment.assigned_at,
        expires_at: assignment.expires_at,
        is_active: assignment.active?,
        custom_permissions: assignment.custom_permissions_hash
      }
    end
  end
end

