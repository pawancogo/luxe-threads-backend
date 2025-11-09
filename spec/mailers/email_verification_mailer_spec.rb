require 'rails_helper'

RSpec.describe EmailVerificationMailer, type: :mailer do
  let(:user) { create(:user, email: 'user@example.com') }
  let(:verification) { create(:email_verification, verifiable: user, email: user.email) }

  describe '#send_otp' do
    let(:mail) { EmailVerificationMailer.send_otp(verification) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Verify Your Email - LuxeThreads')
      expect(mail.to).to eq(['user@example.com'])
      expect(mail.from).to be_present
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(verification.otp)
      expect(mail.body.encoded).to include('verify')
    end

    it 'includes verification URL' do
      expect(mail.body.encoded).to include('verify-email')
    end
  end
end

