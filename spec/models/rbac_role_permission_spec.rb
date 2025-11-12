require 'rails_helper'

RSpec.describe RbacRolePermission, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:rbac_role_id) }
    it { should validate_presence_of(:rbac_permission_id) }
  end

  describe 'associations' do
    it { should belong_to(:rbac_role) }
    it { should belong_to(:rbac_permission) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      role_permission = build(:rbac_role_permission)
      expect(role_permission).to be_valid
    end
  end
end





