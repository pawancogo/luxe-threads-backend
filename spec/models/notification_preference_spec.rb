require 'rails_helper'

RSpec.describe NotificationPreference, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of(:user_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:preference) { create(:notification_preference, user: user) }

    describe '#preferences_hash' do
      it 'returns parsed preferences' do
        preference.update(preferences: '{"email": {"order_updates": true}}')
        expect(preference.preferences_hash).to have_key('email')
      end

      it 'returns default preferences when blank' do
        preference.update(preferences: nil)
        expect(preference.preferences_hash).to have_key('email')
        expect(preference.preferences_hash).to have_key('sms')
      end
    end

    describe '#get_preference' do
      it 'returns preference value' do
        preference.set_preference('email', 'order_updates', true)
        expect(preference.get_preference('email', 'order_updates')).to be true
      end
    end

    describe '#set_preference' do
      it 'sets preference value' do
        preference.set_preference('email', 'promotions', false)
        expect(preference.get_preference('email', 'promotions')).to be false
      end
    end
  end
end

