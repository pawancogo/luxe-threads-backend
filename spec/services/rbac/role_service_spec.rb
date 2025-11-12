require 'rails_helper'

RSpec.describe Rbac::RoleService, type: :service do
  let(:admin) { create(:admin) }
  let(:rbac_role) { create(:rbac_role) }

  describe '.assign_role_to_admin' do
    it 'assigns role to admin' do
      expect {
        described_class.assign_role_to_admin(
          admin: admin,
          role_slug: rbac_role.slug,
          assigned_by: admin
        )
      }.to change(AdminRoleAssignment, :count).by(1)
    end

    it 'creates assignment with expiration' do
      expires_at = 30.days.from_now
      
      assignment = described_class.assign_role_to_admin(
        admin: admin,
        role_slug: rbac_role.slug,
        assigned_by: admin,
        expires_at: expires_at
      )
      
      expect(assignment.expires_at).to be_within(1.second).of(expires_at)
    end
  end

  describe '.remove_role_from_admin' do
    let!(:assignment) { create(:admin_role_assignment, admin: admin, rbac_role: rbac_role) }

    it 'removes role from admin' do
      expect {
        described_class.remove_role_from_admin(
          admin: admin,
          role_slug: rbac_role.slug,
          removed_by: admin
        )
      }.to change(AdminRoleAssignment, :count).by(-1)
    end
  end
end





