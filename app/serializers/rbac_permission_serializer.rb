# frozen_string_literal: true

# Serializer for RBAC Permission API responses
class RbacPermissionSerializer < BaseSerializer
  attributes :id, :name, :slug, :resource_type, :action, :category, :full_permission
end

