require 'rails_helper'

RSpec.describe WishlistCreationService, type: :service do
  let(:user) { create(:user) }

  describe '#call' do
    it 'creates wishlist for user' do
      service = WishlistCreationService.new(user)
      
      expect {
        service.call
      }.to change(Wishlist, :count).by(1)
      
      expect(service.success?).to be true
      expect(user.reload.wishlist).to be_present
    end

    it 'does not create duplicate wishlist' do
      create(:wishlist, user: user)
      
      service = WishlistCreationService.new(user)
      service.call
      
      expect(Wishlist.where(user: user).count).to eq(1)
    end

    it 'returns existing wishlist if present' do
      existing_wishlist = create(:wishlist, user: user)
      
      service = WishlistCreationService.new(user)
      result = service.call
      
      expect(result.wishlist).to eq(existing_wishlist)
    end
  end
end





