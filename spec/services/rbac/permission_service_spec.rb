require 'rails_helper'

RSpec.describe Rbac::PermissionService, type: :service do
  let(:permission) { create(:rbac_permission) }
  let(:role) { create(:rbac_role) }

  describe '.grant_permission_to_role' do
    it 'grants permission to role' do
      expect {
        described_class.grant_permission_to_role(role, permission)
      }.to change(RbacRolePermission, :count).by(1)
    end
  end

  describe '.revoke_permission_from_role' do
    let!(:role_permission) { create(:rbac_role_permission, rbac_role: role, rbac_permission: permission) }

    it 'revokes permission from role' do
      expect {
        described_class.revoke_permission_from_role(role, permission)
      }.to change(RbacRolePermission, :count).by(-1)
    end
  end

  describe '.role_permissions' do
    let!(:role_permission) { create(:rbac_role_permission, rbac_role: role, rbac_permission: permission) }

    it 'returns permissions for role' do
      permissions = described_class.role_permissions(role)
      expect(permissions).to include(permission)
    end
  end
end





