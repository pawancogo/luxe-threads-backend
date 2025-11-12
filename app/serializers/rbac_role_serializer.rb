# frozen_string_literal: true

# Serializer for RBAC Role API responses
class RbacRoleSerializer < BaseSerializer
  attributes :id, :name, :slug, :role_type, :description, :priority, :permissions

  def permissions
    object.rbac_permissions.active.pluck(:slug)
  end
end

