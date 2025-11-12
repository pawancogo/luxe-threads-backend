require 'rails_helper'

RSpec.describe Api::V1::ProductViewsController, type: :controller do
  let(:product) { create(:product) }

  before do
    allow(controller).to receive(:feature_enabled?).and_return(true)
  end

  describe 'POST #track' do
    it 'tracks product view without authentication' do
      expect {
        post :track, params: { product_id: product.id }
      }.to change(ProductView, :count).by(1)
      
      expect(response).to have_http_status(:ok)
    end

    it 'tracks product view with authenticated user' do
      user = create(:user)
      auth_headers = { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" }
      request.headers.merge!(auth_headers)
      
      post :track, params: { product_id: product.id }
      
      expect(response).to have_http_status(:ok)
      view = ProductView.last
      expect(view.user_id).to eq(user.id)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





