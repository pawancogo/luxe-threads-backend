require 'rails_helper'

RSpec.describe CartCreationService, type: :service do
  let(:user) { create(:user) }

  describe '#call' do
    it 'creates cart for user' do
      service = CartCreationService.new(user)
      
      expect {
        service.call
      }.to change(Cart, :count).by(1)
      
      expect(service.success?).to be true
      expect(user.reload.cart).to be_present
    end

    it 'does not create duplicate cart' do
      create(:cart, user: user)
      
      service = CartCreationService.new(user)
      service.call
      
      expect(Cart.where(user: user).count).to eq(1)
    end
  end
end





