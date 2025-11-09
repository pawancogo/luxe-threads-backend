require 'rails_helper'

RSpec.describe Verifiable, type: :concern do
  let(:user) { create(:user) }

  before do
    user.class.include(Verifiable)
  end

  describe 'associations' do
    it 'has many email_verifications' do
      expect(user).to respond_to(:email_verifications)
    end
  end

  describe '#send_verification_email' do
    it 'delegates to EmailVerificationService' do
      expect(EmailVerificationService).to receive(:new).with(user).and_return(double(send_verification_email: true))
      user.send_verification_email
    end
  end

  describe '#resend_verification_email' do
    it 'delegates to EmailVerificationService' do
      expect(EmailVerificationService).to receive(:new).with(user).and_return(double(resend_verification_email: true))
      user.resend_verification_email
    end
  end

  describe '#verify_email_with_otp' do
    it 'delegates to EmailVerificationService' do
      service = double(verify_email_with_otp: true)
      expect(EmailVerificationService).to receive(:new).with(user).and_return(service)
      user.verify_email_with_otp('123456')
    end
  end

  describe '#verification_status' do
    it 'delegates to EmailVerificationService' do
      service = double(verification_status: 'verified')
      expect(EmailVerificationService).to receive(:new).with(user).and_return(service)
      user.verification_status
    end
  end
end

