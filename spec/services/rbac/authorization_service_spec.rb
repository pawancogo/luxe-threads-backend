require 'rails_helper'

RSpec.describe Rbac::AuthorizationService, type: :service do
  let(:admin) { create(:admin) }
  let(:permission) { create(:rbac_permission, name: 'products:view') }
  let(:role) { create(:rbac_role) }

  before do
    create(:rbac_role_permission, rbac_role: role, rbac_permission: permission)
    create(:admin_role_assignment, admin: admin, rbac_role: role)
  end

  describe '.can_perform?' do
    it 'returns true if admin has permission' do
      expect(described_class.can_perform?(admin, 'products:view')).to be true
    end

    it 'returns false if admin lacks permission' do
      expect(described_class.can_perform?(admin, 'products:delete')).to be false
    end
  end

  describe '.has_role?' do
    it 'returns true if admin has role' do
      expect(described_class.has_role?(admin, role.slug)).to be true
    end

    it 'returns false if admin lacks role' do
      other_role = create(:rbac_role, slug: 'other_role')
      expect(described_class.has_role?(admin, other_role.slug)).to be false
    end
  end
end





