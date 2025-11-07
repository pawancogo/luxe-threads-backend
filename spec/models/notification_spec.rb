# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:notification_type) }
  end

  describe 'enums' do
    it { should define_enum_for(:notification_type).with_values(
      order_update: 'order_update',
      payment: 'payment',
      promotion: 'promotion',
      review: 'review',
      system: 'system',
      shipping: 'shipping'
    ) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      notification = build(:notification)
      expect(notification).to be_valid
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:read_notification) { create(:notification, user: user, is_read: true) }
    let!(:unread_notification) { create(:notification, user: user, is_read: false) }

    it 'filters unread notifications' do
      expect(user.notifications.where(is_read: false)).to include(unread_notification)
      expect(user.notifications.where(is_read: false)).not_to include(read_notification)
    end
  end

  describe 'methods' do
    let(:notification) { create(:notification, data: { order_id: 123, status: 'shipped' }.to_json) }

    it 'parses data JSON' do
      expect(notification.data_hash).to be_a(Hash)
      expect(notification.data_hash['order_id']).to eq(123)
    end

    it 'sets data hash' do
      notification.data_hash = { test: 'value' }
      expect(notification.data).to eq('{"test":"value"}')
    end
  end
end

