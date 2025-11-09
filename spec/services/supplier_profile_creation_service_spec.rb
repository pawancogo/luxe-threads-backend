require 'rails_helper'

RSpec.describe SupplierProfileCreationService, type: :service do
  let(:supplier_user) { create(:user, :supplier) }

  describe '#call' do
    it 'creates supplier profile for supplier user' do
      service = SupplierProfileCreationService.new(supplier_user)
      
      expect {
        service.call
      }.to change(SupplierProfile, :count).by(1)
      
      expect(supplier_user.reload.supplier_profile).to be_present
    end

    it 'does not create profile for non-supplier user' do
      customer = create(:user)
      service = SupplierProfileCreationService.new(customer)
      
      expect {
        service.call
      }.not_to change(SupplierProfile, :count)
    end

    it 'returns existing profile if present' do
      existing_profile = create(:supplier_profile, user: supplier_user)
      service = SupplierProfileCreationService.new(supplier_user)
      
      result = service.call
      expect(result).to eq(existing_profile)
    end

    it 'creates profile with custom options' do
      service = SupplierProfileCreationService.new(
        supplier_user,
        company_name: 'Test Company',
        gst_number: 'GST123456'
      )
      
      profile = service.call
      expect(profile.company_name).to eq('Test Company')
      expect(profile.gst_number).to eq('GST123456')
    end
  end
end

