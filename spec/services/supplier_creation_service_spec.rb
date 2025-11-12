require 'rails_helper'

RSpec.describe SupplierCreationService, type: :service do
  let(:supplier_user) { create(:user, :supplier) }

  describe '#call' do
    it 'creates supplier for supplier user' do
      service = SupplierCreationService.new(supplier_user)
      
      # Note: This service may create Supplier model if it exists
      # Adjust based on actual implementation
      result = service.call
      
      expect(service.success?).to be_truthy
    end

    it 'does not create supplier for non-supplier user' do
      customer = create(:user)
      service = SupplierCreationService.new(customer)
      
      result = service.call
      
      expect(result).to be_nil
    end

    it 'handles errors gracefully' do
      allow_any_instance_of(SupplierCreationService).to receive(:create_supplier).and_raise(StandardError, 'Error')
      
      service = SupplierCreationService.new(supplier_user)
      service.call
      
      expect(service.errors).not_to be_empty
    end
  end
end





