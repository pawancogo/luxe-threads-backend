# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportTicketMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:support_ticket) }
  end

  describe 'validations' do
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:sender_type) }
    it { should validate_presence_of(:sender_id) }
    it { should validate_length_of(:message).is_at_least(1).is_at_most(5000) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      message = build(:support_ticket_message)
      expect(message).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sanitizes message content' do
      message = build(:support_ticket_message, message: '<script>alert("xss")</script>Hello')
      message.save
      expect(message.message).not_to include('<script>')
    end
  end

  describe 'scopes' do
    let(:ticket) { create(:support_ticket) }
    let!(:user_message) { create(:support_ticket_message, support_ticket: ticket, is_internal: false) }
    let!(:internal_message) { create(:support_ticket_message, :internal, support_ticket: ticket) }

    it 'filters visible messages' do
      visible = ticket.support_ticket_messages.visible_to_user
      expect(visible).to include(user_message)
      expect(visible).not_to include(internal_message)
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }
    let(:ticket) { create(:support_ticket, user: user) }
    let(:message) { create(:support_ticket_message, support_ticket: ticket, sender_type: 'user', sender_id: user.id) }

    it 'returns sender user' do
      expect(message.sender).to eq(user)
    end

    it 'parses attachments JSON' do
      message.attachments = [{ url: 'test.jpg', type: 'image' }].to_json
      message.save
      expect(message.attachments_list).to be_a(Array)
      expect(message.attachments_list.first['url']).to eq('test.jpg')
    end

    it 'marks as read' do
      expect(message.is_read).to be false
      message.mark_as_read!
      expect(message.is_read).to be true
      expect(message.read_at).to be_present
    end
  end
end

