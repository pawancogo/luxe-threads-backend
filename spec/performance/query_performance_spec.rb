# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query Performance', type: :performance do
  describe 'Orders queries' do
    let!(:user) { create(:user) }
    let!(:orders) { create_list(:order, 50, user: user) }

    it 'efficiently queries orders by user and status' do
      expect {
        Order.where(user_id: user.id, status: 'pending').order(created_at: :desc).to_a
      }.to perform_under(100).ms
    end

    it 'efficiently queries orders by status' do
      expect {
        Order.where(status: 'pending').order(created_at: :desc).limit(20).to_a
      }.to perform_under(100).ms
    end
  end

  describe 'Product queries' do
    let!(:supplier) { create(:supplier_profile) }
    let!(:category) { create(:category) }
    let!(:products) { create_list(:product, 100, supplier_profile: supplier, category: category) }

    it 'efficiently queries products by supplier and status' do
      expect {
        Product.where(supplier_profile_id: supplier.id, status: 'active').order(created_at: :desc).to_a
      }.to perform_under(150).ms
    end

    it 'efficiently queries active products by category' do
      expect {
        Product.where(category_id: category.id, status: 'active').to_a
      }.to perform_under(150).ms
    end
  end

  describe 'Notification queries' do
    let!(:user) { create(:user) }
    let!(:notifications) { create_list(:notification, 100, user: user, is_read: false) }
    let!(:read_notifications) { create_list(:notification, 50, user: user, is_read: true) }

    it 'efficiently queries unread notifications' do
      expect {
        Notification.where(user_id: user.id, is_read: false).order(created_at: :desc).to_a
      }.to perform_under(100).ms
    end
  end

  describe 'Support ticket queries' do
    let!(:user) { create(:user) }
    let!(:tickets) { create_list(:support_ticket, 50, user: user, status: 'open') }

    it 'efficiently queries tickets by user and status' do
      expect {
        SupportTicket.where(user_id: user.id, status: 'open').order(created_at: :desc).to_a
      }.to perform_under(100).ms
    end
  end
end

