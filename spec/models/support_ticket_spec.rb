# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportTicket, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:assigned_to).class_name('Admin').optional }
    it { should belong_to(:resolved_by).class_name('Admin').optional }
    it { should belong_to(:order).optional }
    it { should belong_to(:product).optional }
    it { should have_many(:support_ticket_messages).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
  end

  describe 'enums' do
    it { should define_enum_for(:category).with_values(
      order_issue: 'order_issue',
      product_issue: 'product_issue',
      payment_issue: 'payment_issue',
      account_issue: 'account_issue',
      other: 'other'
    ) }

    it { should define_enum_for(:status).with_values(
      open: 'open',
      in_progress: 'in_progress',
      waiting_customer: 'waiting_customer',
      resolved: 'resolved',
      closed: 'closed'
    ) }

    it { should define_enum_for(:priority).with_values(
      low: 'low',
      medium: 'medium',
      high: 'high',
      urgent: 'urgent'
    ) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      ticket = build(:support_ticket)
      expect(ticket).to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates ticket_id on create' do
      ticket = build(:support_ticket, ticket_id: nil)
      ticket.save
      expect(ticket.ticket_id).to be_present
      expect(ticket.ticket_id).to match(/^TKT-[A-Z0-9]+$/)
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:open_ticket) { create(:support_ticket, user: user, status: 'open') }
    let!(:resolved_ticket) { create(:support_ticket, user: user, status: 'resolved') }

    it 'filters by status' do
      expect(user.support_tickets.where(status: 'open')).to include(open_ticket)
      expect(user.support_tickets.where(status: 'open')).not_to include(resolved_ticket)
    end
  end
end

