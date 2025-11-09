require 'rails_helper'

RSpec.describe EmailVerification, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:otp) }
    it { should validate_length_of(:otp).is_equal_to(6) }
    it { should validate_presence_of(:verifiable_type) }
    it { should validate_presence_of(:verifiable_id) }
  end

  describe 'associations' do
    it { should belong_to(:verifiable) }
  end

  describe 'scopes' do
    describe '.pending' do
      it 'returns unverified verifications' do
        pending = create(:email_verification, verified_at: nil)
        verified = create(:email_verification, verified_at: Time.current)
        expect(EmailVerification.pending).to include(pending)
        expect(EmailVerification.pending).not_to include(verified)
      end
    end

    describe '.expired' do
      it 'returns expired verifications' do
        expired = create(:email_verification, created_at: 20.minutes.ago)
        active = create(:email_verification, created_at: 5.minutes.ago)
        expect(EmailVerification.expired).to include(expired)
        expect(EmailVerification.expired).not_to include(active)
      end
    end
  end

  describe 'callbacks' do
    it 'generates OTP before validation' do
      verification = build(:email_verification, otp: nil)
      verification.valid?
      expect(verification.otp).to be_present
      expect(verification.otp.length).to eq(6)
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:verification) { create(:email_verification, verifiable: user) }

    describe '#verified?' do
      it 'returns true when verified' do
        verification.update(verified_at: Time.current)
        expect(verification.verified?).to be true
      end
    end

    describe '#verify!' do
      it 'verifies with correct OTP' do
        otp = verification.otp
        expect(verification.verify!(otp)).to be true
        expect(verification.verified_at).to be_present
      end

      it 'fails with incorrect OTP' do
        expect(verification.verify!('000000')).to be false
      end
    end
  end
end

