# frozen_string_literal: true

# Service for updating role permissions
# Follows Single Responsibility - only handles permission updates for roles
module Rbac
  class RolePermissionsUpdateService < BaseService
    attr_reader :role

    def initialize(role, permission_ids)
      super()
      @role = role
      @permission_ids = Array(permission_ids).map(&:to_i).compact.uniq
    end

    def call
      validate_role!
      update_permissions
      set_result(@role)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_role!
      unless @role.is_a?(RbacRole)
        add_error('Invalid role')
        raise StandardError, 'Role must be a RbacRole instance'
      end
    end

    def update_permissions
      with_transaction do
        # Remove existing permissions
        @role.rbac_role_permissions.destroy_all

        # Add new permissions
        @permission_ids.each do |permission_id|
          permission = RbacPermission.find_by(id: permission_id)
          next unless permission

          @role.rbac_role_permissions.create!(rbac_permission: permission)
        end
      end
    end
  end
end

