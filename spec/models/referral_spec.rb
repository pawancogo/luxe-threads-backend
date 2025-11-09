require 'rails_helper'

RSpec.describe Referral, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:referrer_id).scoped_to(:referred_id) }
  end

  describe 'associations' do
    it { should belong_to(:referrer).class_name('User') }
    it { should belong_to(:referred).class_name('User') }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      completed: 'completed',
      rewarded: 'rewarded'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.by_referrer' do
      it 'returns referrals by referrer' do
        referrer = create(:user)
        referral = create(:referral, referrer: referrer)
        expect(Referral.by_referrer(referrer.id)).to include(referral)
      end
    end
  end

  describe 'instance methods' do
    let(:referral) { create(:referral, status: 'pending') }

    describe '#mark_completed!' do
      it 'marks referral as completed' do
        referral.mark_completed!
        expect(referral.status).to eq('completed')
        expect(referral.completed_at).to be_present
      end
    end

    describe '#mark_rewarded!' do
      it 'marks referral as rewarded' do
        referral.update(status: 'completed')
        referral.mark_rewarded!
        expect(referral.status).to eq('rewarded')
      end
    end
  end
end

