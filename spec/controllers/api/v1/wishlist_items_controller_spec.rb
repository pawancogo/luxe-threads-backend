require 'rails_helper'

RSpec.describe Api::V1::WishlistItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:wishlist) { create(:wishlist, user: user) }
  let(:product_variant) { create(:product_variant) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge!(headers)
  end

  describe 'POST #create' do
    it 'creates a new wishlist item' do
      post :create, params: { 
        wishlist_item: { 
          wishlist_id: wishlist.id,
          product_variant_id: product_variant.id
        } 
      }
      
      expect(response).to have_http_status(:created)
      expect(WishlistItem.count).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    let(:wishlist_item) { create(:wishlist_item, wishlist: wishlist, product_variant: product_variant) }

    it 'deletes wishlist item' do
      delete :destroy, params: { id: wishlist_item.id }
      
      expect(response).to have_http_status(:success)
      expect(WishlistItem.exists?(wishlist_item.id)).to be false
    end
  end
end
