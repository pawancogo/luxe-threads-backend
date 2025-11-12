# frozen_string_literal: true

# Serializer for Admin Role Assignment API responses
class AdminRoleAssignmentSerializer < BaseSerializer
  attributes :id, :admin_id, :role, :assigned_by, :assigned_at, :expires_at,
             :is_active, :custom_permissions

  def role
    RbacRoleSerializer.new(object.rbac_role).as_json
  end

  def assigned_by
    object.assigned_by&.full_name
  end

  def is_active
    object.active?
  end

  def custom_permissions
    object.custom_permissions_hash
  end
end

