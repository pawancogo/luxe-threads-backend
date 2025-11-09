require 'rails_helper'

RSpec.describe AdminRoleAssignment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:admin_id) }
    it { should validate_presence_of(:rbac_role_id) }
  end

  describe 'associations' do
    it { should belong_to(:admin) }
    it { should belong_to(:rbac_role) }
    it { should belong_to(:assigned_by).class_name('Admin').optional }
  end

  describe 'factory' do
    it 'has a valid factory' do
      assignment = build(:admin_role_assignment)
      expect(assignment).to be_valid
    end
  end
end

