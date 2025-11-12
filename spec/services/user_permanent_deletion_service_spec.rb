require 'rails_helper'

RSpec.describe UserPermanentDeletionService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe '.delete' do
    it 'deletes user permanently' do
      expect {
        described_class.delete(user)
      }.to change(User, :count).by(-1)
    end
  end

  describe '#delete' do
    it 'permanently deletes user' do
      user_id = user.id
      service.delete
      
      expect(User.find_by(id: user_id)).to be_nil
    end

    it 'cleans up user dependencies' do
      # Create dependencies
      address = create(:address, user: user)
      cart = create(:cart, user: user)
      cart_item = create(:cart_item, cart: cart)
      
      service.delete
      
      expect(Address.find_by(id: address.id)).to be_nil
      expect(Cart.find_by(id: cart.id)).to be_nil
      expect(CartItem.find_by(id: cart_item.id)).to be_nil
    end

    it 'handles errors gracefully' do
      allow(user).to receive(:really_destroy!).and_raise(StandardError, 'Deletion failed')
      
      expect {
        service.delete
      }.to raise_error(StandardError)
    end
  end
end





