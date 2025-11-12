require 'rails_helper'

RSpec.describe Api::V1::ReviewsController, type: :controller do
  let(:user) { create(:user) }
  let(:product) { create(:product, status: 'active') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ user_id: user.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns product reviews without authentication' do
      request.headers.delete('Authorization')
      create(:review, product: product, rating: 5)
      
      get :index, params: { product_id: product.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(1)
    end

    it 'filters by featured reviews' do
      create(:review, product: product, is_featured: true)
      create(:review, product: product, is_featured: false)
      
      get :index, params: { product_id: product.id, featured: 'true' }
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].all? { |r| r['is_featured'] }).to be true
    end
  end

  describe 'POST #create' do
    let(:order_item) { create(:order_item, order: create(:order, user: user, status: 'delivered')) }

    it 'creates review' do
      expect {
        post :create, params: {
          product_id: product.id,
          review: {
            rating: 5,
            comment: 'Great product!',
            order_item_id: order_item.id
          }
        }
      }.to change(Review, :count).to(1)
      
      expect(response).to have_http_status(:created)
    end

    it 'returns error for invalid rating' do
      post :create, params: {
        product_id: product.id,
        review: {
          rating: 6,
          comment: 'Invalid'
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #vote' do
    let(:review) { create(:review, product: product, user: user) }

    it 'votes helpful on review' do
      post :vote, params: {
        product_id: product.id,
        id: review.id,
        is_helpful: true
      }
      
      expect(response).to have_http_status(:ok)
      review.reload
      expect(review.helpful_count).to eq(1)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





