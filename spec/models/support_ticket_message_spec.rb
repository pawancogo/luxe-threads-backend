require 'rails_helper'

RSpec.describe SupportTicketMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:support_ticket) }
    it { should belong_to(:user).optional }
    it { should belong_to(:admin).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:message) }
  end

  describe 'enums' do
    it { should define_enum_for(:message_type).with_values(user_message: 'user_message', admin_message: 'admin_message', system_message: 'system_message') }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:support_ticket_message)).to be_valid
    end
  end
end
