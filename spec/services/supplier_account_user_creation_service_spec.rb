require 'rails_helper'

RSpec.describe SupplierAccountUserCreationService, type: :service do
  let(:supplier_profile) { create(:supplier_profile) }
  let(:user) { create(:user) }

  describe '#call' do
    it 'creates supplier account user' do
      service = SupplierAccountUserCreationService.new(supplier_profile, user, role: 'owner')
      
      expect {
        service.call
      }.to change(SupplierAccountUser, :count).by(1)
      
      expect(service.success?).to be true
      expect(service.supplier_account_user).to be_present
    end

    it 'does not create duplicate account user' do
      create(:supplier_account_user, supplier_profile: supplier_profile, user: user)
      
      service = SupplierAccountUserCreationService.new(supplier_profile, user)
      service.call
      
      expect(SupplierAccountUser.where(supplier_profile: supplier_profile, user: user).count).to eq(1)
    end

    it 'creates with staff role' do
      service = SupplierAccountUserCreationService.new(supplier_profile, user, role: 'staff')
      service.call
      
      expect(service.supplier_account_user.role).to eq('staff')
    end
  end
end

