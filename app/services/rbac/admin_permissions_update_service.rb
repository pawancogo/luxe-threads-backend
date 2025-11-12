# frozen_string_literal: true

# Service for updating custom permissions for an admin role assignment
module Rbac
  class AdminPermissionsUpdateService < BaseService
    attr_reader :assignment

    def initialize(admin, role_slug, custom_permissions)
      super()
      @admin = admin
      @role_slug = role_slug
      @custom_permissions = custom_permissions || {}
    end

    def call
      find_assignment!
      update_permissions
      clear_cache
      set_result(@assignment)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def find_assignment!
      @assignment = AdminRoleAssignment.joins(:rbac_role)
                                       .find_by(admin: @admin, rbac_roles: { slug: @role_slug })

      unless @assignment
        add_error('Role assignment not found')
        raise StandardError, 'Role assignment not found'
      end
    end

    def update_permissions
      unless @assignment.update(custom_permissions: @custom_permissions)
        add_errors(@assignment.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @assignment
      end
    end

    def clear_cache
      Rbac::PermissionCacheService.clear_admin_cache(@admin.id)
    end
  end
end

