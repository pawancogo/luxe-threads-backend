require 'rails_helper'

RSpec.describe AdminActivity, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:action) }
  end

  describe 'associations' do
    it { should belong_to(:admin) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'orders by created_at desc' do
        old = create(:admin_activity, created_at: 2.days.ago)
        recent = create(:admin_activity, created_at: Time.current)
        expect(AdminActivity.recent.first).to eq(recent)
      end
    end
  end

  describe 'class methods' do
    describe '.log_activity' do
      let(:admin) { create(:admin) }

      it 'creates activity log' do
        expect {
          AdminActivity.log_activity(admin, 'created', 'User', 1, description: 'Created user')
        }.to change(AdminActivity, :count).by(1)
      end

      it 'includes all options' do
        activity = AdminActivity.log_activity(
          admin,
          'updated',
          'Product',
          1,
          description: 'Updated product',
          changes: { name: ['Old', 'New'] },
          ip_address: '127.0.0.1'
        )
        expect(activity.description).to eq('Updated product')
        expect(activity.changes_data).to have_key('name')
      end
    end
  end

  describe 'instance methods' do
    let(:activity) { create(:admin_activity) }

    describe '#changes_data' do
      it 'returns parsed changes' do
        activity.update(changes: '{"status": ["pending", "active"]}')
        expect(activity.changes_data).to have_key('status')
      end
    end
  end
end





