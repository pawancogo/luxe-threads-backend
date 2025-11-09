require 'rails_helper'

RSpec.describe RbacAuthorizable, type: :concern do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:supplier_user) { create(:supplier_account_user) }

  describe '#has_permission?' do
    context 'for Admin' do
      it 'returns true for super admin' do
        admin.extend(RbacAuthorizable)
        expect(admin.has_permission?('any:permission')).to be true
      end

      it 'delegates to RBAC service for non-super admin' do
        admin.update(role: 'product_admin')
        admin.extend(RbacAuthorizable)
        expect(Rbac::PermissionService).to receive(:admin_has_permission?).with(admin, 'products:manage')
        admin.has_permission?('products:manage')
      end
    end

    context 'for SupplierAccountUser' do
      it 'delegates to RBAC service' do
        supplier_user.extend(RbacAuthorizable)
        expect(Rbac::PermissionService).to receive(:supplier_user_has_permission?).with(supplier_user, 'products:manage')
        supplier_user.has_permission?('products:manage')
      end
    end
  end

  describe '#permissions' do
    context 'for Admin' do
      it 'returns all permissions for super admin' do
        admin.extend(RbacAuthorizable)
        expect(admin.permissions).to be_an(Array)
      end

      it 'delegates to RBAC service for non-super admin' do
        admin.update(role: 'product_admin')
        admin.extend(RbacAuthorizable)
        expect(Rbac::PermissionService).to receive(:admin_permissions).with(admin)
        admin.permissions
      end
    end
  end

  describe '#has_role?' do
    it 'delegates to RBAC service' do
      admin.extend(RbacAuthorizable)
      expect(Rbac::RoleService).to receive(:admin_has_role?).with(admin, 'product_admin')
      admin.has_role?('product_admin')
    end
  end

  describe '#primary_role' do
    it 'delegates to RBAC service' do
      admin.extend(RbacAuthorizable)
      expect(Rbac::RoleService).to receive(:admin_primary_role).with(admin)
      admin.primary_role
    end
  end
end

