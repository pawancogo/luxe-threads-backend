require 'rails_helper'

RSpec.describe SupplierAccountUser, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:supplier_profile_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:supplier_profile) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      supplier_account_user = build(:supplier_account_user)
      expect(supplier_account_user).to be_valid
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active account users' do
        active_user = create(:supplier_account_user, is_active: true)
        inactive_user = create(:supplier_account_user, is_active: false)
        
        expect(SupplierAccountUser.active).to include(active_user)
        expect(SupplierAccountUser.active).not_to include(inactive_user)
      end
    end
  end
end

