require 'rails_helper'

RSpec.describe Api::V1::CouponsController, type: :controller do
  describe 'GET #index' do
    it 'returns available coupons' do
      create_list(:coupon, 3, active: true)
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'filters active coupons only' do
      active = create(:coupon, active: true)
      inactive = create(:coupon, active: false)
      
      get :index
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].map { |c| c['id'] }).to include(active.id)
      expect(json_response['data'].map { |c| c['id'] }).not_to include(inactive.id)
    end
  end

  describe 'GET #show' do
    it 'returns coupon details' do
      coupon = create(:coupon)
      get :show, params: { id: coupon.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(coupon.id)
    end
  end

  describe 'POST #validate' do
    it 'validates coupon code' do
      coupon = create(:coupon, code: 'SAVE20', active: true)
      post :validate, params: { code: 'SAVE20' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['valid']).to be true
    end

    it 'returns invalid for expired coupon' do
      coupon = create(:coupon, code: 'EXPIRED', expires_at: 1.day.ago)
      post :validate, params: { code: 'EXPIRED' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['valid']).to be false
    end
  end
end
