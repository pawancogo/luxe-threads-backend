require 'rails_helper'

RSpec.describe UserResourceCreationService, type: :service do
  let(:user) { create(:user) }

  describe '#call' do
    it 'creates cart and wishlist for user' do
      service = UserResourceCreationService.new(user)
      
      expect {
        service.call
      }.to change(Cart, :count).by(1)
       .and change(Wishlist, :count).by(1)
      
      expect(service.success?).to be true
    end

    it 'creates supplier resources for supplier user' do
      supplier = create(:user, :supplier)
      service = UserResourceCreationService.new(supplier)
      
      service.call
      
      expect(supplier.reload.supplier_profile).to be_present
    end

    it 'does not create resources for non-persisted user' do
      new_user = build(:user)
      service = UserResourceCreationService.new(new_user)
      
      service.call
      
      expect(service.success?).to be false
    end
  end
end





