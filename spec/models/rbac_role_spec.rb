require 'rails_helper'

RSpec.describe RbacRole, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:role_type) }
    it { should validate_presence_of(:priority) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_uniqueness_of(:name).scoped_to(:role_type) }
    it { should validate_inclusion_of(:role_type).in_array(%w[admin supplier system]) }
    it { should validate_numericality_of(:priority).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:rbac_role_permissions).dependent(:destroy) }
    it { should have_many(:rbac_permissions).through(:rbac_role_permissions) }
    it { should have_many(:admin_role_assignments).dependent(:destroy) }
    it { should have_many(:admins).through(:admin_role_assignments) }
    it { should have_many(:supplier_account_users).dependent(:nullify) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active roles' do
        active = create(:rbac_role, is_active: true)
        inactive = create(:rbac_role, is_active: false)
        
        expect(RbacRole.active).to include(active)
        expect(RbacRole.active).not_to include(inactive)
      end
    end
  end

  describe 'callbacks' do
    it 'generates slug from name' do
      role = build(:rbac_role, name: 'Test Role', slug: nil)
      role.valid?
      expect(role.slug).to eq('test_role')
    end
  end

  describe 'instance methods' do
    let(:role) { create(:rbac_role) }

    describe '#can_delete?' do
      it 'returns false for system roles' do
        role.update(is_system: true)
        expect(role.can_delete?).to be false
      end
    end

    describe '#has_permission?' do
      it 'checks if role has permission' do
        permission = create(:rbac_permission, slug: 'products.create')
        role.rbac_permissions << permission
        expect(role.has_permission?('products.create')).to be true
      end
    end
  end
end





