require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:auditable_type) }
    it { should validate_presence_of(:auditable_id) }
    it { should validate_presence_of(:action) }
  end

  describe 'associations' do
    it { should belong_to(:user).optional }
  end

  describe 'enums' do
    it { should define_enum_for(:action).with_values(
      created: 'create',
      updated: 'update',
      deleted: 'delete'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'orders by created_at desc' do
        old = create(:audit_log, created_at: 2.days.ago)
        recent = create(:audit_log, created_at: Time.current)
        expect(AuditLog.recent.first).to eq(recent)
      end
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:audit_log) { create(:audit_log, auditable_type: 'User', auditable_id: user.id) }

    describe '#changes_data' do
      it 'returns parsed changes' do
        audit_log.update(changes: '{"name": ["Old", "New"]}')
        expect(audit_log.changes_data).to have_key('name')
      end
    end

    describe '#auditable' do
      it 'returns auditable object' do
        expect(audit_log.auditable).to eq(user)
      end
    end
  end
end

