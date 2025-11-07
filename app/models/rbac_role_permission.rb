# frozen_string_literal: true

# RBAC Role Permission Join Model
# Links roles to permissions with optional constraints
class RbacRolePermission < ApplicationRecord
  # Associations
  belongs_to :rbac_role
  belongs_to :rbac_permission
  
  # Validations
  validates :rbac_role_id, uniqueness: { scope: :rbac_permission_id }
  
  # Scopes
  scope :active, -> { joins(:rbac_role, :rbac_permission).where(rbac_roles: { is_active: true }, rbac_permissions: { is_active: true }) }
end

