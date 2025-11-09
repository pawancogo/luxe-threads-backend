require 'rails_helper'

RSpec.describe RbacPermission, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:resource_type) }
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:category) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'associations' do
    it { should have_many(:rbac_role_permissions).dependent(:destroy) }
    it { should have_many(:rbac_roles).through(:rbac_role_permissions) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active permissions' do
        active = create(:rbac_permission, is_active: true)
        inactive = create(:rbac_permission, is_active: false)
        expect(RbacPermission.active).to include(active)
        expect(RbacPermission.active).not_to include(inactive)
      end
    end
  end

  describe 'instance methods' do
    let(:permission) { create(:rbac_permission, resource_type: 'products', action: 'create') }

    describe '#full_permission' do
      it 'returns formatted permission string' do
        expect(permission.full_permission).to eq('products:create')
      end
    end

    describe '#can_delete?' do
      it 'returns false for system permissions' do
        permission.update(is_system: true)
        expect(permission.can_delete?).to be false
      end
    end
  end
end

